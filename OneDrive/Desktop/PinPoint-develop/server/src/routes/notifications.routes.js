import { Router } from 'express';
import { requireAuth } from '../middleware/auth.js';
import { asyncHandler } from '../utils/asyncHandler.js';
import {
  acknowledgeNotification,
  archiveNotification,
  assignNotification,
  bulkUpdateNotifications,
  dismissNotification,
  flagNotificationForReview,
  getNotificationEvents,
  listNotifications,
  markNotificationRead,
  rerouteNotification,
} from '../services/notifications.service.js';
import { optionalDateOnly, parsePagination, requireEnum, requireString } from '../utils/validation.js';

const router = Router();
const LIST_STATES = ['active', 'all', 'mine', 'assigned', 'resolved', 'archived', 'new', 'read', 'acknowledged'];
const BULK_ACTIONS = ['acknowledge', 'archive', 'assign', 'mark_read'];

router.use(requireAuth);

router.get(
  '/',
  asyncHandler(async (req, res) => {
    const severity = req.query.severity ? requireString(req.query.severity, 'severity', { max: 16 }).toLowerCase() : undefined;
    const search = req.query.search ? requireString(req.query.search, 'search', { max: 64 }) : undefined;
    const state = req.query.state ? requireEnum(String(req.query.state).toLowerCase(), 'state', LIST_STATES) : 'active';
    const dateFrom = optionalDateOnly(req.query.dateFrom, 'dateFrom');
    const dateTo = optionalDateOnly(req.query.dateTo, 'dateTo');
    const assignedTo = req.query.assignedTo ? requireString(req.query.assignedTo, 'assignedTo', { max: 64 }) : undefined;
    const { page, pageSize } = parsePagination(req.query);

    const result = await listNotifications({
      severity,
      search,
      state,
      page,
      pageSize,
      dateFrom,
      dateTo,
      assignedTo,
      currentUser: req.user,
    });

    res.json(result);
  }),
);

router.get(
  '/:id/events',
  asyncHandler(async (req, res) => {
    const data = await getNotificationEvents({ id: req.params.id, currentUser: req.user });
    res.json({ data });
  }),
);

router.post(
  '/bulk-action',
  asyncHandler(async (req, res) => {
    const action = requireEnum(req.body.action, 'action', BULK_ACTIONS);
    const assigneeId = req.body.assigneeId ? requireString(req.body.assigneeId, 'assigneeId', { max: 64 }) : undefined;
    const data = await bulkUpdateNotifications({
      ids: Array.isArray(req.body.ids) ? req.body.ids : [],
      action,
      actor: req.user,
      assigneeId,
    });
    res.json({ data });
  }),
);

router.post(
  '/:id/dismiss',
  asyncHandler(async (req, res) => {
    const data = await dismissNotification({ id: req.params.id, actor: req.user, expectedVersion: req.body?.expectedVersion });
    res.json({ data });
  }),
);

router.post(
  '/:id/read',
  asyncHandler(async (req, res) => {
    const data = await markNotificationRead({ id: req.params.id, actor: req.user, expectedVersion: req.body?.expectedVersion });
    res.json({ data });
  }),
);

router.post(
  '/:id/acknowledge',
  asyncHandler(async (req, res) => {
    const data = await acknowledgeNotification({ id: req.params.id, actor: req.user, expectedVersion: req.body?.expectedVersion });
    res.json({ data });
  }),
);

router.post(
  '/:id/assign',
  asyncHandler(async (req, res) => {
    const assigneeId = req.body.assigneeId ? requireString(req.body.assigneeId, 'assigneeId', { max: 64 }) : undefined;
    const data = await assignNotification({
      id: req.params.id,
      actor: req.user,
      assigneeId,
      expectedVersion: req.body?.expectedVersion,
    });
    res.json({ data });
  }),
);

router.post(
  '/:id/archive',
  asyncHandler(async (req, res) => {
    const data = await archiveNotification({ id: req.params.id, actor: req.user, expectedVersion: req.body?.expectedVersion });
    res.json({ data });
  }),
);

router.post(
  '/:id/flag-review',
  asyncHandler(async (req, res) => {
    const data = await flagNotificationForReview({
      id: req.params.id,
      actor: req.user,
      expectedVersion: req.body?.expectedVersion,
    });
    res.json({ data });
  }),
);

router.post(
  '/:id/reroute',
  asyncHandler(async (req, res) => {
    const data = await rerouteNotification({
      id: req.params.id,
      actor: req.user,
      expectedVersion: req.body?.expectedVersion,
    });
    res.json({ data });
  }),
);

export default router;
