import { useEffect, useState } from "react";
import { Link, useNavigate } from "react-router-dom";
import { FiUser } from "react-icons/fi";
import { config } from "../../../config";

type User = {
  first_name: string;
  last_name: string;
  email: string;
  role: string;
};

interface ProfileMenuProps {
  asCard?: boolean;
}

const ProfileMenu = ({ asCard = false }: ProfileMenuProps) => {
  const navigate = useNavigate();
  const [profileOpen, setProfileOpen] = useState(false);
  const [user, setUser] = useState<User | null>(null);
  const [error, setError] = useState<string | null>(null);

  const loadUser = () => {
    const storedUser = localStorage.getItem("user");

    if (storedUser) {
      setUser(JSON.parse(storedUser));
    } else {
      setUser(null);
    }
  };

  useEffect(() => {
    loadUser();

    window.addEventListener("authChange", loadUser);

    return () => {
      window.removeEventListener("authChange", loadUser);
    };
  }, []);

  const handleLogout = async () => {
    const token = localStorage.getItem("access_token");

    try {
      if (token) {
        const response = await fetch(`${config.baseUrl}/logout`, {
          method: "POST",
          headers: {
            Authorization: `Bearer ${token}`,
          },
        });

        if (!response.ok) {
          const data = await response.json();

          if (data.error !== "token_expired") {
            throw new Error(
              data.message || data.description || "Logout failed."
            );
          }
        }
      }
    } catch (error) {
      console.error("Logout warning:", error);

      setError(
        error instanceof Error ? error.message : "Logout failed"
      );
    } finally {
      localStorage.removeItem("access_token");
      localStorage.removeItem("refresh_token");
      localStorage.removeItem("user");

      setUser(null);
      setProfileOpen(false);

      window.dispatchEvent(new Event("authChange"));
      navigate("/login");
    }
  };

  // Card used on the Profile page
  if (asCard) {
    return (
      <div className="w-full max-w-sm bg-white rounded-xl shadow-lg border border-gray-200 p-6 text-gray-900 text-sm">
        <h3 className="font-semibold text-lg mb-3">
          My Account
        </h3>

        {error && (
          <p className="text-red-500 text-xs text-center mt-2">
            {error}
          </p>
        )}

        {user ? (
          <>
            <div className="border-b border-gray-200 pb-3 mb-3">
              <p className="font-semibold">
                Hello {user.first_name}
              </p>

              <p className="text-gray-500 text-sm">
                {user.email}
              </p>
            </div>

            <button
              onClick={handleLogout}
              className="w-full bg-red-500 text-white py-2 rounded-md hover:bg-red-600 transition"
            >
              Logout
            </button>
          </>
        ) : (
          <>
            <p className="text-gray-500 mb-4">
              You are not logged in.
            </p>

            <Link
              to="/login"
              className="block w-full bg-sky-500 text-white text-center py-2 rounded-md hover:bg-sky-600 transition"
            >
              Login
            </Link>
          </>
        )}
      </div>
    );
  }

  // ORIGINAL HEADER PROFILE MENU
  return (
    <div className="relative">
      <button
        onClick={() => setProfileOpen(!profileOpen)}
        className="focus:outline-none"
      >
        <FiUser className="hover:text-skyText duration-200 cursor-pointer text-2xl" />
      </button>

      {profileOpen && (
        <div className="absolute right-0 top-10 w-64 bg-white rounded-xl shadow-lg border border-gray-200 p-4 text-gray-900 text-sm z-50">
          <h3 className="font-semibold text-lg mb-3">
            My Account
          </h3>

          {error && (
            <p className="text-red-500 text-xs text-center mt-2">
              {error}
            </p>
          )}

          {user ? (
            <>
              <div className="border-b border-gray-200 pb-3 mb-3">
                <p className="font-semibold">
                  Hello {user.first_name}
                </p>

                <p className="text-gray-500 text-sm">
                  {user.email}
                </p>
              </div>

              <button
                onClick={handleLogout}
                className="w-full bg-red-500 text-white py-2 rounded-md hover:bg-red-600 transition"
              >
                Logout
              </button>
            </>
          ) : (
            <>
              <p className="text-gray-500 mb-4">
                You are not logged in.
              </p>

              <Link
                to="/login"
                onClick={() => setProfileOpen(false)}
                className="block w-full bg-sky-500 text-white text-center py-2 rounded-md hover:bg-sky-600 transition"
              >
                Login
              </Link>
            </>
          )}
        </div>
      )}
    </div>
  );
};

export default ProfileMenu;