import { useState } from "react";
import { useNavigate } from "react-router-dom";
import { config } from "../../../config";

const DeleteAccount = () => {
  const navigate = useNavigate();

  const [loading, setLoading] = useState(false);
  const [message, setMessage] = useState("");

  const handleDelete = async () => {
    const token = localStorage.getItem("access_token");

    if (!token) return;

    try {
      setLoading(true);

      const response = await fetch(`${config.baseUrl}/profile`, {
        method: "DELETE",
        headers: {
          Authorization: `Bearer ${token}`,
        },
      });

      if (!response.ok) {
        const data = await response.json();
        throw new Error(data.message || "Failed to delete account.");
      }

      // Log the user out after deleting
      localStorage.removeItem("access_token");
      localStorage.removeItem("refresh_token");
      localStorage.removeItem("user");

      window.dispatchEvent(new Event("authChange"));

      navigate("/login");
    } catch (error) {
      if (error instanceof Error) {
        setMessage(error.message);
      } else {
        setMessage("Failed to delete account.");
      }
    } finally {
      setLoading(false);
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

      <div className="border border-red-300 rounded-xl p-6">
        <h1 className="text-2xl font-bold text-red-600 mb-4">
          Delete Account
        </h1>

        <p className="text-gray-700 mb-4">
          You're about to permanently delete your Tech Traders account.
        </p>

        <div className="bg-red-50 border border-red-200 rounded-lg p-4 mb-6">
          <p className="font-medium text-red-700 mb-2">
            This action cannot be undone.
          </p>

          <ul className="list-disc list-inside text-red-700 text-sm space-y-1">
            <li>Your account will be permanently deleted.</li>
            <li>Your saved addresses will be removed.</li>
            <li>Your shopping cart will be deleted.</li>
            <li>You will be signed out immediately.</li>
          </ul>
        </div>

        {message && (
          <p className="text-red-600 mb-4">{message}</p>
        )}

        <div className="flex gap-3">
          <button
            onClick={() => navigate("/profile")}
            className="flex-1 border border-gray-300 py-2 rounded hover:bg-gray-100 transition"
          >
            Cancel
          </button>

          <button
            onClick={handleDelete}
            disabled={loading}
            className="flex-1 bg-red-600 text-white py-2 rounded hover:bg-red-700 disabled:opacity-50 transition"
          >
            {loading ? "Deleting..." : "Yes, Delete My Account"}
          </button>
        </div>
      </div>
    </div>
  );
};

export default DeleteAccount;