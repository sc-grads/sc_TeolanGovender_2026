import { IoClose, IoSearchOutline } from "react-icons/io5";
import { useEffect, useState } from "react";
import {
  Menu,
  MenuButton,
  MenuItem,
  MenuItems,
  Transition,
} from "@headlessui/react";
//import { FaChevronDown } from "react-icons/fa";
import { FiShoppingBag, FiStar, FiUser } from "react-icons/fi";
import { Link, useNavigate } from "react-router-dom";
import { logo } from "../assets/images";
import Container from "../ui/Container";
import { config } from "../../config";
import { getData } from "../lib";
import { type CategoryProps } from "../../type";
import ProfileMenu from "./account/ProfileMenu";

const bottomNavigation = [
  { title: "Product Management", link: "/product" },
  { title: "Order Management", link: "/order-management" },
  //{ title: "Account Management", link: "/profile" },
];

const Header = () => {
  const navigate = useNavigate();

  const [searchText, setSearchText] = useState("");
  const [categories, setCategories] = useState<CategoryProps[]>([]);
  const [profileOpen, setProfileOpen] = useState(false);

  const [user, setUser] = useState<{
    name: string;
    email: string;
    role: string;
  } | null>(null);

  useEffect(() => {
    const storedUser = localStorage.getItem("user");

    if (storedUser) {
      setUser(JSON.parse(storedUser));
    }

    const fetchData = async () => {
      const endpoint = `${config.baseUrl}/category`;

      try {
        const data = await getData(endpoint);
        setCategories(data);
      } catch (error) {
        console.error("Error fetching categories", error);
      }
    };

    fetchData();
  }, []);

    const handleLogout = async () => {
    const token = localStorage.getItem("access_token");

    if (!token) return;

    try {
      const response = await fetch(`${config.baseUrl}/logout`, {
        method: "POST",
        headers: {
          Authorization: `Bearer ${token}`,
        },
      });

      if (!response.ok) {
        throw new Error("Logout failed.");
      }

      localStorage.removeItem("access_token");
      localStorage.removeItem("refresh_token");
      localStorage.removeItem("user");

      setUser(null);
      setProfileOpen(false);

      navigate("/");
    } catch (error) {
      console.error("Logout error:", error);
    }
  };

  return (
    <div className="w-full bg-whiteText md:sticky md:top-0 z-50">
      <div className="max-w-screen-xl mx-auto h-20 flex items-center justify-between px-4 lg:px-0">
        {/* Logo */}
        <Link to="/">
          <img src={logo} alt="logo" className="w-44" />
        </Link>

        {/* SearchBar */}
        <div className="hidden md:inline-flex max-w-3xl w-full relative">
          <input
            type="text"
            onChange={(e) => setSearchText(e.target.value)}
            value={searchText}
            placeholder="Search products..."
            className="w-full flex-1 rounded-full text-gray-900 text-lg placeholder:text-base placeholder:tracking-wide shadow-sm ring-1 ring-inset ring-gray-300 placeholder:text-gray-400 placeholder:font-normal focus:ring-1 focus:ring-darkText sm:text-sm px-4 py-2"
          />

          {searchText ? (
            <IoClose
              onClick={() => setSearchText("")}
              className="absolute top-2.5 right-4 text-xl hover:text-red-500 cursor-pointer duration-200"
            />
          ) : (
            <IoSearchOutline className="absolute top-2.5 right-4 text-xl" />
          )}
        </div>

        {/* Menubar */}
        <div className="flex items-center gap-x-6 text-2xl">
          <ProfileMenu />
        </div>
      </div>

      <div className="w-full bg-darkText text-whiteText">
        <Container className="py-2 max-w-4xl flex items-center gap-5 justify-between">
          <div className="py-2.5">
            <Menu>
              <Transition
                enter="transition ease-out duration-75"
                enterFrom="opacity-0 scale-95"
                enterTo="opacity-100 scale-100"
                leave="transition ease-in duration-100"
                leaveFrom="opacity-100 scale-100"
                leaveTo="opacity-0 scale-95"
              >
                <MenuItems
                  anchor="bottom end"
                  className="w-52 origin-top-right rounded-xl border border-white/5 bg-black p-1 text-sm/6 text-gray-300 [--anchor-gap:var(--spacing-1)] focus:outline-none hover:text-white z-50"
                >
                  {categories.map((item) => (
                    <MenuItem key={item.category_id}>
                      <Link
                        to={`/category/${item.category_id}`}
                        className="flex w-full items-center gap-2 rounded-lg py-2 px-3 data-[focus]:bg-white/20 tracking-wide"
                      >
                        {item.name}
                      </Link>
                    </MenuItem>
                  ))}
                </MenuItems>
              </Transition>
            </Menu>
          </div>

          {bottomNavigation.map(({ title, link }) => (
            <Link
              to={link}
              key={title}
              className="uppercase hidden md:inline-flex text-sm font-semibold text-whiteText/90 hover:text-whiteText duration-200 relative overflow-hidden group"
            >
              {title}

              <span className="inline-flex w-full h-[1px] bg-whiteText absolute bottom-0 left-0 transform -translate-x-[105%] group-hover:translate-x-0 duration-300" />
            </Link>
          ))}
        </Container>
      </div>
    </div>
  );
};

export default Header;