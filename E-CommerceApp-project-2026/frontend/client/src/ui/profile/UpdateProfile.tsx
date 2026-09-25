import { useEffect, useState } from "react";
import { useNavigate } from "react-router-dom";
import { config } from "../../../config";

const UpdateProfile = () => {
  const navigate = useNavigate();

  const [first_name, setFirstName] = useState("");
  const [last_name, setLastName] = useState("");
  const [email, setEmail] = useState("");
  const [phoneNumber, setPhoneNumber] = useState("");

  const [message, setMessage] = useState("");

  const fetchProfile = async () => {
    const token = localStorage.getItem("access_token");

    const response = await fetch(`${config.baseUrl}/profile`, {
      headers: {
        Authorization: `Bearer ${token}`,
      },
    });

    if (response.ok) {
      const data = await response.json();

      setFirstName(data.first_name);
      setLastName(data.last_name);
      setEmail(data.email);
      setPhoneNumber(data.phone_number || "");
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
      }),
    });

    const data = await response.json();

    if (response.ok) {
      const user = JSON.parse(localStorage.getItem("user") || "{}");

      user.first_name = data.first_name;
      user.last_name = data.last_name;
      user.email = data.email;

      localStorage.setItem("user", JSON.stringify(user));
      window.dispatchEvent(new Event("authChange"));

      setMessage("Profile updated successfully.");
    } else {
      setMessage(data.message || "Could not update profile.");
    }
  };

  return (
    <div className="max-w-2xl mx-auto p-5">
      <button
        onClick={() => navigate("/profile")}
        className="text-sky-600 hover:underline mb-5"
      >
        ← Back to Profile
      </button>

      <h1 className="text-2xl font-bold mb-6">Update Details</h1>

      {message && (
        <p className="mb-5 text-green-600">{message}</p>
      )}

      <form
        onSubmit={updateProfile}
        className="border-2 border-slate-500 rounded-lg p-4 mb-6"
      >
        <div>
          <label className="block mb-1">First Name:</label>
          <input
            type="text"
            value={first_name}
            onChange={(e) => setFirstName(e.target.value)}
            className="w-full border border-slate-300 rounded p-2"
            required
          />
        </div>

        <div>
          <label className="block mb-1">Last Name:</label>
          <input
            type="text"
            value={last_name}
            onChange={(e) => setLastName(e.target.value)}
            className="w-full border border-slate-300 rounded p-2"
            required
          />
        </div>

        <div>
          <label className="block mb-1">Email:</label>
          <input
            type="email"
            value={email}
            onChange={(e) => setEmail(e.target.value)}
            className="w-full border border-slate-300 rounded p-2"
            required
          />
        </div>

        <div>
          <label className="block mb-1">Phone Number:</label>
          <input
            type="text"
            value={phoneNumber}
            onChange={(e) => setPhoneNumber(e.target.value)}
            className="w-full border border-slate-300 rounded p-2"
          />
        </div>

        <div className="p-2">
        <button
          type="submit"
          className="bg-black text-white px-4 p-10 py-2 rounded hover:bg-gray-800 transition"
        >
          Save Changes
        </button>
        </div>
      </form>
    </div>
  );
};

export default UpdateProfile;