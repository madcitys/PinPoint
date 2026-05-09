import { supabase } from '../lib/supabase.js';
import { PARCEL_STATUSES } from '../utils/constants.js';
import { throwIfSupabaseError } from '../utils/database.js';
import { getMonthRange } from '../utils/date.js';

export async function getDashboardSummary(month) {
  const range = getMonthRange(month);

  const statusCountRequests = PARCEL_STATUSES.map((status) =>
    supabase
      .from('parcels')
      .select('id', { count: 'exact', head: true })
      .eq('status', status)
      .gte('date_added', range.startDate)
      .lt('date_added', range.endDate),
  );

  const [statusResults, reportsResult, historyResult] = await Promise.all([
    Promise.all(statusCountRequests),
    supabase
      .from('parcel_reports')
      .select('id,tracking_number,remarks,status,reported_at')
      .eq('status', 'Unresolved')
      .order('reported_at', { ascending: false })
      .limit(5),
    supabase
      .from('activity_logs')
      .select('id,tracking_number,action,category,actor_name,created_at')
      .order('created_at', { ascending: false })
      .limit(5),
  ]);

  for (const result of statusResults) {
    throwIfSupabaseError(result.error);
  }

  throwIfSupabaseError(reportsResult.error);
  throwIfSupabaseError(historyResult.error);

  const totals = Object.fromEntries(PARCEL_STATUSES.map((status, index) => [status, statusResults[index].count ?? 0]));

  return {
    month: range.month,
    monthLabel: range.label,
    totals,
    chart: PARCEL_STATUSES.map((status) => ({
      label: status,
      value: totals[status] ?? 0,
    })),
    unresolvedReports: (reportsResult.data ?? []).map((report) => ({
      id: report.id,
      trackingNumber: report.tracking_number,
      remarks: report.remarks,
      status: report.status,
      reportedAt: report.reported_at,
    })),
    recentHistory: (historyResult.data ?? []).map((entry) => ({
      id: entry.id,
      trackingNumber: entry.tracking_number,
      action: entry.action,
      category: entry.category,
      actorName: entry.actor_name,
      date: entry.created_at,
    })),
  };
}
