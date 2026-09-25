import { useEffect, useState } from "react";
import { useNavigate } from "react-router-dom";
import { config } from "../../../config";
import AddressSelector from "./AddressSelector";
import ProfileMenu from "../account/ProfileMenu";

const Profile = () => {
  const navigate = useNavigate();

  const [first_name, setFirstName] = useState("");
  const [last_name, setLastName] = useState("");
  const [email, setEmail] = useState("");
  const [phoneNumber, setPhoneNumber] = useState("");

  const [message, setMessage] = useState("");

  const [isLoggedIn, setIsLoggedIn] = useState(true);

  const fetchProfile = async () => {
    const token = localStorage.getItem("access_token");

    if (!token) {
      setIsLoggedIn(false);
      return;
    }

    const response = await fetch(`${config.baseUrl}/profile`, {
      headers: {
        Authorization: `Bearer ${token}`,
      },
    });

    if (!response.ok) {
      localStorage.removeItem("access_token");
      localStorage.removeItem("refresh_token");
      localStorage.removeItem("user");
      window.dispatchEvent(new Event("authChange"));

      setIsLoggedIn(false);
      return;
    }

    const data = await response.json();

    setFirstName(data.first_name);
    setLastName(data.last_name);
    setEmail(data.email);
    setPhoneNumber(data.phone_number || "");
    setIsLoggedIn(true);
  };

  useEffect(() => {
    fetchProfile();
  }, []);

  /*
  const updateProfile = async (e: React.FormEvent) => {
    e.preventDefault();

    const token = localStorage.getItem("access_token");

    const response = await fetch(`${config.baseUrl}/profile`, {
      method: "PATCH",
      headers: {
        "Content-Type": "application/json",
        Authorization: `Bearer ${token}`,
      },
      body: JSON.stringify({
        first_name,
        last_name,
        email,
        phone_number: phoneNumber,
      }),
    });

    if (response.ok) {
      const data = await response.json();

      const user = JSON.parse(
        localStorage.getItem("user") || "{}"
      );

      user.first_name = data.first_name;
      user.last_name = data.last_name;
      user.email = data.email;

      localStorage.setItem("user", JSON.stringify(user));

      setMessage("Profile updated successfully.");
    } else {
      setMessage("Could not update profile.");
    }
  };
  */

  if (!isLoggedIn) {
    return (
      <div className="max-w-2xl mx-auto p-5">
        <h1 className="text-2xl font-bold mb-6">My Profile</h1>
    
        <div className="border-2 border-slate-500 rounded-xl p-8 flex justify-center">
          <ProfileMenu asCard />
        </div>
      </div>
    );
  }

  return (
    <div className="max-w-2xl mx-auto p-5">
      <h1 className="text-2xl font-bold mb-6">My Profile</h1>

      {message && (
        <p className="mb-5 text-green-600">
          {message}
        </p>
      )}

      {/* personal details */}
      <div className="border-2 border-slate-500 rounded-lg p-4 mb-6">
        <div className="flex items-center justify-between mb-4">
          <h2 className="text-xl font-semibold">Personal Details</h2>
          
          <button
            type="button"
            onClick={() => navigate("/update-profile")}
            className="text-sky-600 hover:underline"
          >
            Update Details
          </button>
        </div>
          
        <div className="space-y-4">
          <div>
            <p className="text-sm text-gray-500">First Name</p>
            <p className="font-medium">{first_name}</p>
          </div>
          
          <div>
            <p className="text-sm text-gray-500">Last Name</p>
            <p className="font-medium">{last_name}</p>
          </div>
          
          <div>
            <p className="text-sm text-gray-500">Email</p>
            <p className="font-medium">{email}</p>
          </div>
          
          <div>
            <p className="text-sm text-gray-500">Phone Number</p>
            <p className="font-medium">{phoneNumber || "Not provided"}</p>
          </div>
        </div>
      </div>

      {/* saved addresses */}
      <div className="border-2 border-slate-500 rounded-lg p-4 mb-6">
        <h2 className="text-xl font-semibold mb-4">
          Saved Addresses
        </h2>

        <button
                  type="button"
                  onClick={() => navigate("/addresses")}
                  className="text-sky-600 p-2 hover:underline mt-3"> Edit </button>

        <AddressSelector />
      </div>

      {/* update password */}
      {/* security */}
      <div className="border-2 border-slate-500 rounded-lg p-4 mb-6">
        <h2 className="text-xl font-semibold mb-2">
          Security
        </h2>
          
        <p className="text-gray-600 mb-4">
          Update your account password.
        </p>
          
        <button
          type="button"
          onClick={() => navigate("/change-password")}
          className="bg-black text-white px-4 py-2 rounded hover:bg-gray-800 transition"
        >
          Change Password
        </button>
      </div>

      {/* delete account */}
      <div className="border-2 border-red-500 rounded-lg p-4 mb-6">
        <h2 className="text-xl font-semibold text-red-600 mb-2">
          Delete Account
        </h2>

        <p className="text-gray-600 mb-4">
          Permanently delete your Tech Traders account and all associated data.
        </p>

        <button
          type="button"
          onClick={() => navigate("/delete-account")}
          className="bg-red-600 text-white px-4 py-2 rounded hover:bg-red-700 transition"
        >
          Delete Account
        </button>
      </div>
    </div>
  );
};

export default Profile;