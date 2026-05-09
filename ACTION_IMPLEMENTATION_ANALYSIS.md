# PinPoint Action Implementation Analysis

## Overview
This document details all six actions requested and their implementations across the codebase.

---

## 1. REROUTE ACTION

### Frontend Implementation
- **Files**: 
  - [src/components/TopNavbar.vue](src/components/TopNavbar.vue#L86) - Alert dropdown menu
  - [src/views/NotificationsPage.vue](src/views/NotificationsPage.vue#L232) - Notifications table
- **Button**: Labeled "Re-route"
- **Handler Function**: 
  ```javascript
  async function rerouteAlert(alert) {
    // TopNavbar.vue lines 361-390
    // NotificationsPage.vue lines 500-521
  ```

### API Implementation
- **API Layer**: [src/lib/alerts.js](src/lib/alerts.js#L113)
  ```javascript
  export async function rerouteAlert(id, expectedVersion) {
    return apiRequest(`/notifications/${id}/reroute`, {
      method: 'POST',
      body: expectedVersion ? { expectedVersion } : {},
    });
  }
  ```

- **API Endpoint**: `POST /api/notifications/{id}/reroute`
- **Backend Handler**: [server/src/routes/notifications.routes.js](server/src/routes/notifications.routes.js#L117)
- **Backend Service**: [server/src/services/notifications.service.js](server/src/services/notifications.service.js#L929-L960)
  ```javascript
  export async function rerouteNotification({ id, actor, expectedVersion }) {
    // Assigns to current user, then resolves alert
    // Creates notification event with type: 'rerouted'
  ```

### Event Emission
**YES** - Emits both events:
```javascript
emitDataEvent(DATA_EVENTS.notificationsRefresh);  // Line 376 (TopNavbar) or 516 (NotificationsPage)
emitDataEvent(DATA_EVENTS.parcelsRefresh);         // Line 376 (TopNavbar) or 516 (NotificationsPage)
```

### Alert State Changes
- **Initial State**: `active` (one of: `new`, `read`, `assigned`)
- **Final State**: `resolved`
- **Event Type**: `'rerouted'`
- **Response Indicates State Change**: **YES** - Backend service explicitly checks `assertActiveAlert()` and changes state to `resolved`

---

## 2. OUTBOUND ACTION

### Frontend Implementation
- **File**: [src/views/OrderRecords.vue](src/views/OrderRecords.vue#L172-L234)
- **Mechanism**: Status dropdown on parcel table row
- **Handler Function**: 
  ```javascript
  function chooseParcelStatus(parcel, status) {
    // Line 642
    await updateParcelStatus(parcel, status)
  ```

### Implementation Details
- **Valid Status Values**: `['Pending', 'Outbound', 'Cancelled', 'Returned', 'Double Waybill', 'Missing', 'Lost']`
- **When User Selects "Outbound"**: Calls `updateParcelStatus(parcel, 'Outbound')`

### API Implementation
- **API Endpoint**: `PATCH /api/parcels/{id}`
- **Payload**: `{ status: 'Outbound' }`
- **Backend Handler**: [server/src/routes/parcels.routes.js](server/src/routes/parcels.routes.js#L76-L88)
- **Backend Service**: [server/src/services/parcels.service.js](server/src/services/parcels.service.js#L218-L276)
  ```javascript
  export async function updateParcel({ id, platform, status, outboundDate, outboundDateProvided, actor })
  ```

### Special Logic
When status changes to `'Outbound'`:
- **Auto-sets outbound_date** to today (if not already set)
- **Logs activity** via `createActivityLog()`

### Event Emission
**YES** - Emits both events:
```javascript
emitDataEvent(DATA_EVENTS.notificationsRefresh);  // Line 816 (OrderRecords.vue)
emitDataEvent(DATA_EVENTS.parcelsRefresh);         // Line 817 (OrderRecords.vue)
```

### Alert State Changes
- **How Alerts Are Affected**: Via automatic backend alert sync (`runAlertSync()`)
  - When parcel status changes to 'Outbound', it's no longer in `ALERT_QUALIFYING_STATUSES` 
  - `ALERT_QUALIFYING_STATUSES = ['Pending', 'Missing', 'Lost']`
  - Any active alert for this parcel becomes "stale"
  - **Stale alerts are automatically RESOLVED** with reason: `'parcel_no_longer_pending'`
  - Event type: `'resolved'`
- **Response Indicates State Change**: **YES** - The API response contains updated parcel data, and frontend polls via `emitDataEvent()` which triggers backend alert sync

---

## 3. RETURN ACTION

### Frontend Implementation
- **File**: [src/views/OrderRecords.vue](src/views/OrderRecords.vue#L172-L234)
- **Mechanism**: Status dropdown on parcel table row
- **Handler Function**: Same as Outbound - `updateParcelStatus(parcel, 'Returned')`

### Implementation Details
- **Status Value**: `'Returned'`
- **Outbound Date Logic**: When status changes FROM 'Outbound' TO 'Returned', the outbound_date is **preserved**
  - Other from-statuses → 'Returned' reset outbound_date to null

### API Implementation
- **API Endpoint**: `PATCH /api/parcels/{id}`
- **Payload**: `{ status: 'Returned' }`
- **Backend Logic**: Same as Outbound action via [server/src/services/parcels.service.js](server/src/services/parcels.service.js#L218)

### Event Emission
**YES** - Same as Outbound:
```javascript
emitDataEvent(DATA_EVENTS.notificationsRefresh);
emitDataEvent(DATA_EVENTS.parcelsRefresh);
```

### Alert State Changes
- **Same as Outbound**: Parcel is removed from `ALERT_QUALIFYING_STATUSES`, so any active alert is **automatically RESOLVED** by the backend
- **Response Indicates State Change**: **YES** - Triggers alert sync on next notifications fetch

---

## 4. CANCELLED ACTION

### Frontend Implementation
- **File**: [src/views/OrderRecords.vue](src/views/OrderRecords.vue#L172-L234)
- **Mechanism**: Status dropdown on parcel table row
- **Handler Function**: Same - `updateParcelStatus(parcel, 'Cancelled')`

### Implementation Details
- **Status Value**: `'Cancelled'`
- **Outbound Date Logic**: When status changes TO 'Cancelled' from non-Outbound status, outbound_date is **reset to null**
  - From 'Outbound' → 'Cancelled' also resets outbound_date

### API Implementation
- **API Endpoint**: `PATCH /api/parcels/{id}`
- **Payload**: `{ status: 'Cancelled' }`
- **Backend Logic**: Same as above via [server/src/services/parcels.service.js](server/src/services/parcels.service.js#L218)

### Event Emission
**YES** - Same as Outbound and Return:
```javascript
emitDataEvent(DATA_EVENTS.notificationsRefresh);
emitDataEvent(DATA_EVENTS.parcelsRefresh);
```

### Alert State Changes
- **Same as Outbound**: Parcel is removed from `ALERT_QUALIFYING_STATUSES`, so any active alert is **automatically RESOLVED** by the backend
- **Response Indicates State Change**: **YES** - Triggers alert sync on next notifications fetch

---

## 5. DOUBLE WAYBILL ACTION

### Frontend Implementation
- **File**: [src/views/OrderRecords.vue](src/views/OrderRecords.vue#L172-L234)
- **Mechanism**: Status dropdown on parcel table row
- **Handler Function**: Same - `updateParcelStatus(parcel, 'Double Waybill')`

### Implementation Details
- **Status Value**: `'Double Waybill'`
- **Outbound Date Logic**: When status changes TO 'Double Waybill' from non-Outbound status, outbound_date is **reset to null**
  - From 'Outbound' → 'Double Waybill' also resets outbound_date

### API Implementation
- **API Endpoint**: `PATCH /api/parcels/{id}`
- **Payload**: `{ status: 'Double Waybill' }`
- **Backend Logic**: Same as above via [server/src/services/parcels.service.js](server/src/services/parcels.service.js#L218)

### Event Emission
**YES** - Same as Outbound, Return, and Cancelled:
```javascript
emitDataEvent(DATA_EVENTS.notificationsRefresh);
emitDataEvent(DATA_EVENTS.parcelsRefresh);
```

### Alert State Changes
- **Same as Outbound**: Parcel is removed from `ALERT_QUALIFYING_STATUSES`, so any active alert is **automatically RESOLVED** by the backend
- **Response Indicates State Change**: **YES** - Triggers alert sync on next notifications fetch

---

## 6. MANUAL REFRESH ACTION

### Frontend Implementation - Notifications Page
- **File**: [src/views/NotificationsPage.vue](src/views/NotificationsPage.vue#L170)
- **Button**: "Refresh" button in header
- **Handler**: 
  ```javascript
  <button class="btn" @click="loadAlerts()" :disabled="loading">
    {{ loading ? 'Refreshing...' : 'Refresh' }}
  </button>
  ```
- **Function** (Lines ~300-330):
  ```javascript
  async function loadAlerts() {
    loading.value = true;
    try {
      const payload = await fetchAlertResponse({
        filter: activeFilter.value,
        search: searchQuery.value.trim(),
        state: stateView.value,
        page: page.value,
        pageSize: perPage,
        dateFrom: dateRange.value[0] ? ... : undefined,
        dateTo: dateRange.value[1] ? ... : undefined,
      });
      alerts.value = payload?.data ?? [];
      meta.value = payload?.meta ?? { ... };
      serverSummary.value = payload?.summary ?? serverSummary.value;
    } catch {
      // Error handling
    } finally {
      loading.value = false;
    }
  }
  ```

### Frontend Implementation - OrderRecords Page
- **File**: [src/views/OrderRecords.vue](src/views/OrderRecords.vue#L14)
- **Button**: "Refresh" button in header
- **Handler**: 
  ```javascript
  <button class="btn" @click="loadParcels(1)" :disabled="parcelsLoading">
    {{ parcelsLoading ? 'Refreshing...' : 'Refresh' }}
  </button>
  ```
- **Function** (Lines ~595-620):
  ```javascript
  async function loadParcels(page = meta.value.page) {
    parcelsLoading.value = true;
    pageError.value = '';
    try {
      const payload = await apiJsonRequest('/parcels', { 
        params: buildParcelParams(page) 
      });
      applyParcelsPayload(payload, page);
    } catch (error) {
      pageError.value = error.message;
      parcels.value = [];
      selectedParcelIds.value = [];
    } finally {
      parcelsLoading.value = false;
    }
  }
  ```

### API Implementation
**NotificationsPage**:
- **API Endpoint**: `GET /api/notifications`
- **Query Parameters**: filter, search, state, page, pageSize, dateFrom, dateTo
- **Response**: Contains `data` (alerts array), `meta` (pagination), `summary` (counts)

**OrderRecords**:
- **API Endpoint**: `GET /api/parcels`
- **Query Parameters**: search, status, platform, dateFrom, dateTo, page, pageSize
- **Response**: Contains `data` (parcels array), `meta` (pagination)

### Event Emission
**NO** - Manual refresh does NOT emit `DATA_EVENTS`:
- **NotificationsPage**: Only updates local state `alerts.value`
- **OrderRecords**: Only updates local state `parcels.value`
- No cross-component synchronization triggered by manual refresh itself
- However, both pages subscribe to DATA_EVENTS for updates from other sources

### Alert State Changes
- **No Direct Alert State Changes**: Manual refresh simply re-fetches current data
- **However**: The backend's `listNotifications()` endpoint calls `syncAlerts()` before returning data
  - This can update parcel statuses automatically (Pending → Missing → Lost based on days pending)
  - This can resolve alerts for parcels no longer in ALERT_QUALIFYING_STATUSES
  - New alerts may be created or existing ones may be reopened
- **Response Indicates State Change**: **YES** - The response data will reflect any alert state changes that occurred during the sync

---

## ALERT STATE CHANGE TRIGGERS - SUMMARY TABLE

| Action | Endpoint | Alert State Changes | How |
|--------|----------|-------------------|-----|
| Reroute | POST /notifications/{id}/reroute | YES (active → resolved) | Explicit service call `rerouteNotification()` |
| Flag for Review | POST /notifications/{id}/flag-review | NO | Logs event but does NOT change alert state |
| Mark Read/Unread | POST /notifications/{id}/read/unread | YES (new ↔ read) | Explicit service calls |
| Outbound Status | PATCH /parcels/{id} | YES (active → resolved, if qualified) | Backend alert sync removes from qualifying statuses |
| Cancelled Status | PATCH /parcels/{id} | YES (active → resolved, if qualified) | Backend alert sync removes from qualifying statuses |
| Returned Status | PATCH /parcels/{id} | YES (active → resolved, if qualified) | Backend alert sync removes from qualifying statuses |
| Double Waybill Status | PATCH /parcels/{id} | YES (active → resolved, if qualified) | Backend alert sync removes from qualifying statuses |
| Manual Refresh (Notifications) | GET /notifications | MAYBE | Depends on backend alert sync results |
| Manual Refresh (OrderRecords) | GET /parcels | MAYBE | Indirect - via emitted events triggering alert refresh |

---

## ALERT SYNC MECHANISM

The backend runs automatic alert sync in two scenarios:

1. **On Alert Fetch**: Every call to `listNotifications()` API triggers `syncAlerts()`
2. **On-Demand**: Via `syncAlerts({ force: true })`

### What Alert Sync Does:
```javascript
// Query parcels in ALERT_QUALIFYING_STATUSES = ['Pending', 'Missing', 'Lost']
// For each parcel:
//   - Check days pending
//   - Auto-update status if needed (Pending → Missing → Lost)
//   - Create or update alert based on days pending + severity

// For "stale" alerts (alert exists but parcel no longer qualifies):
for (const staleAlert of staleAlerts) {
  if (['resolved', 'archived'].includes(staleAlert.state)) {
    continue;  // Already handled, skip
  }
  // Resolve the alert automatically
  await resolveAlertInternally(staleAlert, { reason: 'parcel_no_longer_pending' });
}
```

### Key Points:
- Alerts are auto-resolved with reason `'parcel_no_longer_pending'` when parcel moves away from qualifying statuses
- `ACTIVE_ALERT_STATES = ['new', 'read', 'assigned']` - only these states can have alerts resolved
- Already-resolved or archived alerts are left alone
- Alert sync runs **without any frontend action** - just happens automatically on alert fetches

---

## EVENT EMISSION LOCATIONS

### DATA_EVENTS.notificationsRefresh Emissions:
1. **TopNavbar.vue** Line 333: After `flagForReview()`
2. **TopNavbar.vue** Line 375: After `rerouteAlert()`
3. **TopNavbar.vue** Line 407: After `toggleAlertRead()`
4. **OrderRecords.vue** Line 816: After `updateParcelStatus()`
5. **OrderRecords.vue** Line 855: After `submitReport()`
6. **OrderRecords.vue** Line 268: After `submitAddParcel()`
7. **NotificationsPage.vue** Line 429: After `flagAlertForReview()`
8. **NotificationsPage.vue** Line 516: After `rerouteAlert()`

### DATA_EVENTS.parcelsRefresh Emissions:
1. **TopNavbar.vue** Line 376: After `rerouteAlert()`
2. **OrderRecords.vue** Line 817: After `updateParcelStatus()`
3. **OrderRecords.vue** Line 856: After `submitReport()`
4. **OrderRecords.vue** Line 269: After `submitAddParcel()`
5. **NotificationsPage.vue** Line 516: After `rerouteAlert()`

---

## BULK ACTIONS (OrderRecords.vue)

### Bulk Edit Implementation:
- **File**: [src/views/OrderRecords.vue](src/views/OrderRecords.vue#L762-L800)
- **Dialog**: Modal opened via "Edit" button when parcels selected
- **Fields Supported**: Status only
- **Implementation**:
  ```javascript
  async function updateParcel() {
    await Promise.all(
      editForm.value.ids.map((id) =>
        apiRequest(`/parcels/${id}`, {
          method: 'PATCH',
          body: { status: editForm.value.status }
        })
      )
    )
    await loadParcels(meta.value.page)
    emitDataEvent(DATA_EVENTS.notificationsRefresh)
    emitDataEvent(DATA_EVENTS.parcelsRefresh)
  }
  ```
- **Event Emission**: YES - Same both data events emitted after all updates complete

### Bulk Alert Actions:
- **File**: [src/views/NotificationsPage.vue](src/views/NotificationsPage.vue#L147-L161, #L582-L602)
- **Actions**: 'assign', 'unassign' via `runBulkAction()`
- **API**: `POST /notifications/bulk-action`
- **Note**: Bulk actions on alerts do NOT emit data events within the function, only reload alerts

---

## CONCLUSION

### Summary by Action Type:

**Alert-Specific Actions** (directly modify alert state):
- ✅ **Reroute**: Explicit state change via `rerouteNotification()`, emits events
- ✅ **Flag for Review**: Creates report, logs event, does NOT change alert state
- ✅ **Mark Read/Unread**: Explicit state change, emits events

**Parcel Status Actions** (trigger automatic alert changes):
- ✅ **Outbound, Cancelled, Returned, Double Waybill**: Implicit alert resolution via alert sync when parcel leaves qualifying statuses
- ✅ All emit `DATA_EVENTS.notificationsRefresh` + `DATA_EVENTS.parcelsRefresh`

**Manual Refresh** (triggers data sync):
- ✅ **NotificationsPage & OrderRecords**: Re-fetch data with current filters
- ✅ Indirectly causes alert sync (which may resolve/reopen alerts)
- ❌ Does NOT emit events itself, but receives events from other sources

---

**Document Last Updated**: Current Session
**Codebase Version**: PinPoint-develop - Copy (12)
