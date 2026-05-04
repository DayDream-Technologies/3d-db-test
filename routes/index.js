const express = require("express");
const menuRoutes = require("./menu");
const ordersRoutes = require("./orders");
const reservationsRoutes = require("./reservations");
const waitlistRoutes = require("./waitlist");
const miscRoutes = require("./misc");

function createApiRouter(db) {
  const router = express.Router();
  router.use(menuRoutes(db));
  router.use(ordersRoutes(db));
  router.use(reservationsRoutes(db));
  router.use(waitlistRoutes(db));
  router.use(miscRoutes(db));
  return router;
}

module.exports = createApiRouter;
