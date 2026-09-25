import { Routes, Route } from "react-router-dom";
import HomeBanner from "../ui/home/HomeBanner";
import Categories from "../ui/home/Categories";
import Login from "../ui/account/Login";
import Registration from "../ui/account/Registration";
import Product from "../ui/management/ProductManagement";
import Cart from "../ui/cart/Cart";
import OrderManagement from "../ui/management/OrderManagement";

const AppRoutes = () => {
  return (
    <Routes>

      <Route path="/product" element={<Product />} />
      
      <Route path="/" element={<Product />} />

      <Route path="/login" element={<Login />} />

      <Route path="/register" element={<Registration />} />

      <Route path="/cart" element={<Cart />} />

      <Route path="/order-management" element={<OrderManagement />} />
    </Routes>
  );
};

export default AppRoutes;