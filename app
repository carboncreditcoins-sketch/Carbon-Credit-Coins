// src/app.js
import express from "express";
import cccRoutes from "./ccc/ccc.controller.js";

const app = express();
app.use(express.json());

app.use("/ccc", cccRoutes);

app.listen(3001, () => {
  console.log("CCC API running");
});
