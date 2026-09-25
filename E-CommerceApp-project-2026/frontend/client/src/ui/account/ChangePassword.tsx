import { useState } from "react";
import { useNavigate } from "react-router-dom";
import { config } from "../../../config";

const ChangePassword = () => {
  const navigate = useNavigate();

  const [currentPassword, setCurrentPassword] = useState("");
  const [newPassword, setNewPassword] = useState("");
  const [message, setMessage] = useState("");

  const changePassword = async (e: React.FormEvent) => {
    e.preventDefault();

    const token = localStorage.getItem("access_token");

    const response = await fetch(`${config.baseUrl}/profile/password`, {
      method: "PATCH",
      headers: {
        "Content-Type": "application/json",
        Authorization: `Bearer ${token}`,
      },
      body: JSON.stringify({
        current_password: currentPassword,
        new_password: newPassword,
      }),
    });

    const data = await response.json();

    if (response.ok) {
      setMessage("Password changed successfully.");
      setCurrentPassword("");
      setNewPassword("");
    } else {
      setMessage(data.message || "Could not change password.");
    }
  };

  return (
    <div className="max-w-xl mx-auto p-5">
      <button
        onClick={() => navigate("/profile")}
        className="text-sky-600 hover:underline mb-5"
      >
        ← Back to Profile
      </button>

      <h1 className="text-2xl font-bold mb-6">Change Password</h1>

      {message && (
        <p className="mb-5 text-green-600">{message}</p>
      )}

      <form onSubmit={changePassword} className="space-y-4 border rounded-lg p-5">
        <div>
          <label className="block mb-1">Current Password</label>
          <input
            type="password"
            value={currentPassword}
            onChange={(e) => setCurrentPassword(e.target.value)}
            className="w-full border rounded p-2"
            required
          />
        </div>

        <div>
          <label className="block mb-1">New Password</label>
          <input
            type="password"
            value={newPassword}
            onChange={(e) => setNewPassword(e.target.value)}
            className="w-full border rounded p-2"
            required
          />
        </div>

        <button
          type="submit"
          className="bg-black text-white px-4 py-2 rounded hover:bg-gray-800 transition"
        >
          Save Password
        </button>
      </form>
    </div>
  );
};

export default ChangePassword;