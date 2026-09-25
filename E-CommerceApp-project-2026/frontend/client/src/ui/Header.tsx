import { IoClose, IoSearchOutline } from "react-icons/io5";
import { useEffect, useState } from "react";
import {Menu, MenuButton, MenuItem, MenuItems, Transition,} from "@headlessui/react";
//import { FaChevronDown } from "react-icons/fa";
import { FiShoppingBag, FiStar, FiUser, FiMenu } from "react-icons/fi";
import { Link, useNavigate } from "react-router-dom";
import { logo } from "../assets/images";
import Container from "../ui/Container";
import { config } from "../../config";
import { getData } from "../lib";
import { type CategoryProps } from "../../type";
import { type ProductProps } from "../../type";
import ProfileMenu from "./account/ProfileMenu";
import ProductCard from "./products/ProductCard";

const bottomNavigation = [
  { title: "Home", link: "/" },
  { title: "Shop", link: "/product" },
  { title: "Cart", link: "/cart" },
  { title: "Orders", link: "/orders" },
  { title: "My Account", link: "/profile" },
];

const Header = () => {
  const navigate = useNavigate();

  const [searchText, setSearchText] = useState("");
  const [mobileMenuOpen, setMobileMenuOpen] = useState(false);
  //const [search, setSearch] = useState("");
  const [filteredProducts, setFilteredProducts] = useState<ProductProps[]>([]);;
  const [categories, setCategories] = useState<CategoryProps[]>([]);
  const [products, setProducts] = useState<ProductProps[]>([]);
  //const [products, setProducts] = useState([]);
  //const [profileOpen, setProfileOpen] = useState(false);

  /*
  const fetchProducts = async () => {
    const response = await fetch(`${config.baseUrl}/product`);
    const data = await response.json();
    setProducts(data);
  };

  fetchProducts();
  */
/*
  const filteredProducts = products.filter((product) => {
    const matchesSearch =
      product.name.toLowerCase().includes(searchText.toLowerCase()) ||
      product.description.toLowerCase().includes(searchText.toLowerCase()) ||
      product.product_id.toString().includes(searchText);

      return matchesSearch;
  });
  */

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
        const productData = await getData(`${config.baseUrl}/product`);
        console.log(productData);
        setProducts(productData);
      } catch (error) {
        console.error("Error fetching categories", error);
      }
    };

    fetchData();
  }, []);


  useEffect(() => {
    const filtered = products.filter((item: ProductProps) =>
      item.name.toLowerCase().includes(searchText.toLowerCase()) ||
      item.description.toLowerCase().includes(searchText.toLowerCase()) ||
      item.product_id.toString().includes(searchText)
    );
    setFilteredProducts(filtered);
  }, [searchText, products]);


  /*
  useEffect(() => {
      fetchProducts();
  }, []);
  */
  
  /*useEffect(() => {
    const filtered = products.filter((product: ProductProps) =>
      product.name.toLowerCase().includes(searchText.toLowerCase())
    );
    filteredProducts(filtered);
  },[searchText]);*/
  

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
      //setProfileOpen(false);

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

        {/* desktop SearchBar */}
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

        <div className="md:hidden px-4 pb-3 relative">
          {/* mobile search bar */}
          <input
            type="text"
            onChange={(e) => setSearchText(e.target.value)}
            value={searchText}
            placeholder="Search"
            className="w-full rounded-full text-gray-900 text-lg placeholder:text-base placeholder:tracking-wide shadow-sm ring-1 ring-inset ring-gray-300 placeholder:text-gray-400 placeholder:font-normal focus:ring-1 focus:ring-darkText sm:text-sm px-4 py-2"
          />

          {searchText ? (
            <IoClose
              onClick={() => setSearchText("")}
              className="absolute top-2.5 right-7 text-xl hover:text-red-500 cursor-pointer duration-200"
            />
          ) : (
            <IoSearchOutline
              className="absolute top-2.5 right-7 text-xl"
            />
          )}
        </div>

        {/* Search product will go here */}
        {searchText.trim() && (
          <div className="absolute left-0 top-20 w-full mx-auto max-h-[500px] px-10 py-5 bg-white z-20 overflow-y-scroll text-black shadow-lg shadow-skyText scrollbar-hide">
            {filteredProducts.length > 0 ? (
              <div className="grid grid-cols-1 md:grid-cols-3 lg:grid-cols-5 gap-5">
                {filteredProducts?.map((item: ProductProps) => (
                  <ProductCard
                    key={item?.product_id}
                    product={item}
                    setSearchText={setSearchText}
                  />
                ))}
              </div>
            ) : (
              <div className="py-10 bg-gray-50 w-full flex items-center justify-center border border-gray-600 rounded-md">
                <p className="text-xl font-normal">
                  Nothing matches with your search keywords{" "}
                  <span className="underline underline-offset-2 decoration-[1px] text-red-500 font-semibold">{`(${searchText})`}</span>
                </p>
                . Please try again
              </div>
            )}
          </div>
        )}

        {/* Menubar */}
        <div className="flex items-center gap-x-6 text-2xl">
          <ProfileMenu />
                
          <Link to="/cart" className="relative block">
            <FiShoppingBag className="hover:text-skyText duration-200 cursor-pointer" />
            {/*
            <span className="inline-flex items-center justify-center bg-redText text-whiteText absolute -top-1 -right-2 text-[9px] rounded-full w-4 h-4">
              0
            </span>*/}
          </Link>
        </div>
      </div>

      <div className="w-full bg-darkText text-whiteText">
        <Container className="py-2 max-w-4xl flex items-center gap-5 justify-between">
          <div className="py-2.5">
            {/*
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
            </Menu>*/}
          </div>

          <div className="w-full bg-darkText text-whiteText">
            <Container className="py-2 max-w-4xl flex items-center justify-between">

            {/* Desktop navigation */}
            <div className="hidden md:flex items-center gap-5 justify-between w-full">

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
                  className="uppercase text-sm font-semibold text-whiteText/90 hover:text-whiteText duration-200 relative overflow-hidden group"
                >
                  {title}
              
                  <span className="inline-flex w-full h-[1px] bg-whiteText absolute bottom-0 left-0 transform -translate-x-[105%] group-hover:translate-x-0 duration-300" />
                </Link>
              ))}

            </div>
            
            {/* Mobile menu button */}
            <button
              onClick={() => setMobileMenuOpen(!mobileMenuOpen)}
              className="md:hidden text-2xl"
            >
              {mobileMenuOpen ? <IoClose /> : <FiMenu />}
            </button>
            
          </Container>
            
          {/* Mobile navigation */}
          {mobileMenuOpen && (
            <div className="md:hidden border-t border-white/10">
              <div className="flex flex-col">
          
                {bottomNavigation.map(({ title, link }) => (
                  <Link
                    to={link}
                    key={title}
                    onClick={() => setMobileMenuOpen(false)}
                    className="uppercase px-6 py-3 text-sm font-semibold text-whiteText/90 hover:bg-white/10"
                  >
                    {title}
                  </Link>
                ))}

              </div>
            </div>
          )}
        </div>
        </Container>
      </div>
    </div>
  );
};

export default Header;