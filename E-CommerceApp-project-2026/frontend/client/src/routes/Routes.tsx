import { Routes, Route } from "react-router-dom";
import HomeBanner from "../ui/home/HomeBanner";
import Categories from "../ui/home/CategoryButtons";
import Login from "../ui/account/Login";
import Registration from "../ui/account/Registration";
import Product from "../ui/products/Product";
import Cart from "../ui/cart/Cart";
import Orders from "../ui/order/Orders";
import Profile from "../ui/account/Profile";
import Category from "../ui/products/Category";

const AppRoutes = () => {
  return (
    <Routes>
      <Route path="/" element={<><HomeBanner /><Categories /></>} />

      <Route path="/login" element={<Login />} />

      <Route path="/register" element={<Registration />} />

      <Route path="/product" element={<><Categories /><Product /></>} />

      <Route path="/cart" element={<Cart />} />

      <Route path="/orders" element={<Orders />} />

      <Route path="/profile" element={<Profile />} />

      <Route path="/category/:categoryId" element={<Category />} />
    </Routes>
  );
};

export default AppRoutes;