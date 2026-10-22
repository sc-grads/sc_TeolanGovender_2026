import { Routes, Route } from "react-router-dom";
import HomeBanner from "../ui/home/HomeBanner";
import Policies from "../ui/Policies";
import Categories from "../ui/home/CategoryButtons";
import Login from "../ui/account/Login";
import Registration from "../ui/account/Registration";
import Product from "../ui/products/Product";
import ProductDetails from "../ui/products/ProductDetails";
import Cart from "../ui/cart/Cart";
import Orders from "../ui/order/Orders";
import Profile from "../ui/profile/Profile";
import Category from "../ui/products/Category";
import AddressManagement from "../ui/profile/AddressManagement";
import ChangePassword from "../ui/account/ChangePassword";
import DeleteAccount from "../ui/account/DeleteAccount";
import UpdateProfile from "../ui/profile/UpdateProfile";
import ForgotPassword from "../ui/account/ForgotPassword";


const AppRoutes = () => {
  return (
    <Routes>
      <Route path="/" element={<><HomeBanner /><Categories /></>} />

      <Route path="/login" element={<Login />} />

      <Route path="/forgot-password" element={<ForgotPassword />}/>

      <Route path="/register" element={<Registration />} />

      <Route path="/product" element={<><Categories /><Product /></>} />

      <Route path="/product/:product_id" element={<ProductDetails />} />

      <Route path="/cart" element={<Cart />} />

      <Route path="/orders" element={<Orders />} />

      <Route path="/profile" element={<Profile />} />

      <Route path="/category/:categoryId" element={<Category />} />

      <Route path="/addresses" element={<AddressManagement />} />

      <Route path="/change-password" element={<ChangePassword />} />

      <Route path="/delete-account" element={<DeleteAccount />} />

      <Route path="/update-profile" element={<UpdateProfile />} />

      <Route path='/policies' element={<Policies />} />
    </Routes>
  );
};

export default AppRoutes;