import { useEffect, useState } from "react";
import { useNavigate } from "react-router-dom";
import { config } from "../../../config";

const Profile = () => {
  const navigate = useNavigate();

  const [first_name, setFirstName] = useState("");
  const [last_name, setLastName] = useState("");
  const [email, setEmail] = useState("");
  const [phoneNumber, setPhoneNumber] = useState("");
  const [address, setAddress] = useState("");

  const [currentPassword, setCurrentPassword] = useState("");
  const [newPassword, setNewPassword] = useState("");

  const [message, setMessage] = useState("");

  const fetchProfile = async () => {
    const token = localStorage.getItem("access_token");

    const response = await fetch(`${config.baseUrl}/profile`, {
      headers: {
        Authorization: `Bearer ${token}`,
      },
    });

    const data = await response.json();

    if (response.ok) {
      setFirstName(data.first_name);
      setLastName(data.last_name);
      setEmail(data.email);
      setPhoneNumber(data.phone_number || "");
      setAddress(data.address || "");
    }
  };

  useEffect(() => {
    fetchProfile();
  }, []);

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
        address,
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

  const changePassword = async (e: React.FormEvent) => {
    e.preventDefault();

    const token = localStorage.getItem("access_token");

    const response = await fetch(
      `${config.baseUrl}/profile/password`,
      {
        method: "PATCH",
        headers: {
          "Content-Type": "application/json",
          Authorization: `Bearer ${token}`,
        },
        body: JSON.stringify({
          current_password: currentPassword,
          new_password: newPassword,
        }),
      }
    );

    if (response.ok) {
      setCurrentPassword("");
      setNewPassword("");
      setMessage("Password changed successfully.");
    } else {
      const data = await response.json();
      setMessage(data.message || "Could not change password.");
    }
  };

  const deleteAccount = async () => {
    const confirmed = window.confirm(
      "Are you sure you want to delete your account?"
    );

    if (!confirmed) {
      return;
    }

    const token = localStorage.getItem("access_token");

    const response = await fetch(`${config.baseUrl}/profile`, {
      method: "DELETE",
      headers: {
        Authorization: `Bearer ${token}`,
      },
    });

    if (response.ok) {
      localStorage.removeItem("access_token");
      localStorage.removeItem("refresh_token");
      localStorage.removeItem("user");

      window.dispatchEvent(new Event("authChange"));

      navigate("/login");
    }
  };

  return (
    <div className="max-w-2xl mx-auto p-5">
      <h1 className="text-2xl font-bold mb-6">My Profile</h1>
      {message && (<p className="mb-5 text-green-600">{message}</p>)}

      {/* update personal details */}
      <div className="border rounded-lg p-5 mb-6">
        <h2 className="text-xl font-semibold mb-4"> Personal Details </h2>

        <form onSubmit={updateProfile} className="space-y-4">
          <div>
            <label className="block mb-1"> First name</label>
            <input type="text" value={first_name} onChange={(e) => setFirstName(e.target.value)} className="w-full border rounded p-2"/>
          </div>

          <div>
            <label className="block mb-1"> Last name</label>
            <input type="text" value={last_name} onChange={(e) => setLastName(e.target.value)} className="w-full border rounded p-2"/>
          </div>

          <div>
            <label className="block mb-1">Email</label>
            <input type="email"value={email}onChange={(e) => setEmail(e.target.value)}className="w-full border rounded p-2"/>
          </div>

          <div>
            <label className="block mb-1">Phone Number</label>
            <input type="text"value={phoneNumber}onChange={(e) => setPhoneNumber(e.target.value)}className="w-full border rounded p-2"/>
          </div>

          <div>
            <label className="block mb-1">Address</label>
            <input type="text" value={address}onChange={(e) => setAddress(e.target.value)}className="w-full border rounded p-2"/>
          </div>

          <button type="submit" className="bg-black text-white px-4 py-2 rounded"> Save Changes </button>
        </form>
      </div>


      {/* update password */}
      <div className="border rounded-lg p-5 mb-6">
        <h2 className="text-xl font-semibold mb-4"> Change Password </h2>

        <form onSubmit={changePassword} className="space-y-4">
          <div>
            <label className="block mb-1"> Current Password </label>
            <input type="password" value={currentPassword}onChange={(e) =>setCurrentPassword(e.target.value)}className="w-full border rounded p-2"/>
          </div>

          <div>
            <label className="block mb-1">New Password</label>
            <input type="password" value={newPassword}onChange={(e) =>setNewPassword(e.target.value)}className="w-full border rounded p-2"/>
          </div>

          <button type="submit" className="bg-black text-white px-4 py-2 rounded"> Change Password </button>
        </form>
      </div>


      {/* delete account */}
      <div className="border border-red-300 rounded-lg p-5">
        <h2 className="text-xl font-semibold text-red-600 mb-2"> Delete Account </h2>

        <p className="text-gray-600 mb-4"> This will permanently delete your account. </p>

        <button onClick={deleteAccount} className="bg-red-600 text-white px-4 py-2 rounded"> Delete Account </button>
      </div>
    </div>
  );
};

export default Profile;