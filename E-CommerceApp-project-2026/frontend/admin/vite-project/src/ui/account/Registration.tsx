import { useState } from "react";
import { useNavigate } from "react-router-dom";
import { config } from "../../../config";

const Registration = () => {
  const [loading, setLoading] = useState(false);
  const [errMsg, setErrMsg] = useState("");

  const navigate = useNavigate();

  const handleRegistration = async (
    e: React.FormEvent<HTMLFormElement>
  ) => {
    e.preventDefault();
    setErrMsg("");

    const formData = new FormData(e.currentTarget);

    const first_name = formData.get("first_name") as string;
    const last_name = formData.get("last_name") as string;
    const email = formData.get("email") as string;
    const password = formData.get("password") as string;
    const department = formData.get("department") as string;

    try {
      setLoading(true);

      const response = await fetch(`${config.baseUrl}/register`, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          first_name,
          last_name,
          email,
          password,
          role: "employee",
          department,
        }),
      });

      const data = await response.json();

      if (!response.ok) {
        throw new Error(data.message || "Registration failed.");
      }

      console.log("Employee registration successful:", data);

      // Send the employee to login after registering
      navigate("/login");
    } catch (error) {
      console.error("Employee registration error:", error);

      if (error instanceof Error) {
        setErrMsg(error.message);
      } else {
        setErrMsg("An error occurred. Please try again.");
      }
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="min-h-[70vh] flex items-center justify-center px-4 py-12">
      <div className="w-full max-w-md bg-white rounded-xl shadow-md border border-gray-200 p-8">
        {/* Heading */}
        <div className="text-center mb-8">
          <h1 className="text-3xl font-semibold text-darkText">
            Create Employee Account
          </h1>
          <p className="text-gray-500 mt-2">
            Create a Tech Traders admin account
          </p>
        </div>

        <form onSubmit={handleRegistration} className="space-y-5">
          {/* Name */}
          <div>
            <label htmlFor="first_name" className="block text-sm font-medium text-gray-700 mb-2"> First Name </label>
            <input id="first_name" type="text" name="first_name" required placeholder="Enter your name" className="w-full rounded-md border border-gray-300 px-4 py-2.5 outline-none focus:ring-2 focus:ring-sky-500"
            />
          </div>

          {/* LAst Name */}
          <div>
            <label htmlFor="last_name" className="block text-sm font-medium text-gray-700 mb-2"> Last Name </label>
            <input id="last_name" type="text" name="last_name" required placeholder="Enter your name" className="w-full rounded-md border border-gray-300 px-4 py-2.5 outline-none focus:ring-2 focus:ring-sky-500"
            />
          </div>

          {/* Email */}
          <div>
            <label
              htmlFor="email"
              className="block text-sm font-medium text-gray-700 mb-2"
            >
              Email
            </label>
            <input
              id="email"
              type="email"
              name="email"
              required
              placeholder="Enter employee email"
              className="w-full rounded-md border border-gray-300 px-4 py-2.5 outline-none focus:ring-2 focus:ring-sky-500"
            />
          </div>

          {/* Password */}
          <div>
            <label
              htmlFor="password"
              className="block text-sm font-medium text-gray-700 mb-2"
            >
              Password
            </label>
            <input
              id="password"
              type="password"
              name="password"
              required
              placeholder="Create a password"
              className="w-full rounded-md border border-gray-300 px-4 py-2.5 outline-none focus:ring-2 focus:ring-sky-500"
            />
          </div>

          {/* Department */}
          <div>
            <label
              htmlFor="department"
              className="block text-sm font-medium text-gray-700 mb-2"
            >
              Department
            </label>
            <input
              id="department"
              type="text"
              name="department"
              required
              placeholder="Enter department"
              className="w-full rounded-md border border-gray-300 px-4 py-2.5 outline-none focus:ring-2 focus:ring-sky-500"
            />
          </div>

          {/* Error */}
          {errMsg && (
            <p className="text-sm text-red-500 bg-red-50 border border-red-200 rounded-md p-3">
              {errMsg}
            </p>
          )}

          {/* Register */}
          <button
            type="submit"
            disabled={loading}
            className="w-full bg-darkText text-white py-2.5 rounded-md font-medium hover:bg-gray-800 transition disabled:opacity-50 disabled:cursor-not-allowed"
          >
            {loading ? "Creating account..." : "Create Employee Account"}
          </button>
        </form>

        {/* Login link */}
        <div className="text-center mt-6">
          <p className="text-sm text-gray-500">
            Already have an employee account?{" "}
            <button
              type="button"
              onClick={() => navigate("/login")}
              className="text-sky-600 font-medium hover:underline"
            >
              Login
            </button>
          </p>
        </div>
      </div>
    </div>
  );
};

export default Registration;