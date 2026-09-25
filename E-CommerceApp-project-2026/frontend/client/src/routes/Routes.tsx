import { Routes, Route } from "react-router-dom";
import HomeBanner from "../ui/home/HomeBanner";
import Categories from "../ui/home/CategoryButtons";
import Login from "../ui/account/Login";
import Registration from "../ui/account/Registration";
import Product from "../ui/products/Product";
import Cart from "../ui/cart/Cart";
import Orders from "../ui/order/Orders";
import Profile from "../ui/profile/Profile";
import Category from "../ui/products/Category";
import AddressManagement from "../ui/profile/AddressManagement";
import ChangePassword from "../ui/account/ChangePassword";
import DeleteAccount from "../ui/account/DeleteAccount";
import UpdateProfile from "../ui/profile/UpdateProfile";


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

      <Route path="/addresses" element={<AddressManagement />} />

      <Route path="/change-password" element={<ChangePassword />} />

      <Route path="/delete-account" element={<DeleteAccount />} />

      <Route path="/update-profile" element={<UpdateProfile />} />
    </Routes>
  );
};

export default AppRoutes;