import express from "express";
import {
  createOrder,
  getUserOrders,
  getOrderById,
  updateOrderStatus,
} from "../controller/orderController.js";

const router = express.Router();

router.post("/", createOrder);                 // create order
router.get("/user/:userId", getUserOrders);    // user orders
router.get("/:id", getOrderById);              // single order
router.put("/:id/status", updateOrderStatus);  // update status

export default router;
