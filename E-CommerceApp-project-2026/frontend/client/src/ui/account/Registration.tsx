import { useState } from "react";
import { useNavigate } from "react-router-dom";
import { config } from "../../../config";
import AddAddress, { type AddressFormData } from "../profile/AddAddress";

const Registration = () => {
  const navigate = useNavigate();

  const emailPattern = /^[^\s@]+@[^\s@]+$/;
  const passwordPattern = /^(?=.*\d)(?=.*[^A-Za-z0-9]).+$/;

  const [address, setAddress] = useState<AddressFormData>({
    address_line_1: "",
    address_line_2: "",
    city: "",
    province: "",
    postal_code: "",
  });

  const handleRegistration = async (
    e: React.FormEvent<HTMLFormElement>
  ) => {
    e.preventDefault();

    const formData = new FormData(e.currentTarget);

    const response = await fetch(`${config.baseUrl}/register`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        first_name: formData.get("first_name"),
        last_name: formData.get("last_name"),
        email: formData.get("email"),
        password: formData.get("password"),
        role: "customer",
        phone_number: formData.get("phone_number"),
        ...address,
      }),
    });

    if (response.ok) {
      navigate("/login");
    }
  };

  return (
    <div className="min-h-[70vh] flex items-center justify-center px-4 py-12">
      <div className="w-full max-w-md bg-white rounded-xl shadow-md border border-gray-200 p-8">

        <div className="text-center mb-8">
          <h1 className="text-3xl font-semibold text-darkText">
            Create Account
          </h1>

          <p className="text-gray-500 mt-2">
            Create your Tech Traders customer account
          </p>
        </div>

        <form onSubmit={handleRegistration} className="space-y-5">

          {/* first name field*/}
          <div>
            <label
              htmlFor="first_name"
              className="block text-sm font-medium text-gray-700 mb-2"> First Name </label>

            <input
              id="first_name"
              type="text"
              name="first_name"
              required
              placeholder="Enter your name"
              className="w-full rounded-md border border-gray-300 px-4 py-2.5 outline-none focus:ring-2 focus:ring-sky-500"/>
          </div>

          {/* last name field*/}
          <div>
            <label
              htmlFor="last_name"
              className="block text-sm font-medium text-gray-700 mb-2"> Last Name </label>

            <input
              id="last_name"
              type="text"
              name="last_name"
              required
              placeholder="Enter your name"
              className="w-full rounded-md border border-gray-300 px-4 py-2.5 outline-none focus:ring-2 focus:ring-sky-500"/>
          </div>

          {/* Email */}
          <div>
            <label htmlFor="email"
            className="block text-sm font-medium text-gray-700 mb-2" > Email </label>
            <input id="email"
            type="email"
            name="email"
            required pattern={emailPattern.source}
            title="Please enter a valid email address containing @"
            placeholder="Enter your email"
            className="w-full rounded-md border border-gray-300 px-4 py-2.5 outline-none focus:ring-2 focus:ring-sky-500" />
          </div>

          {/* Password */}
          <div>
            <label htmlFor="password"
            className="block text-sm font-medium text-gray-700 mb-2" > Password </label>
            <input id="password"
            type="password"
            name="password"
            required pattern={passwordPattern.source}
            title="Password must contain at least 1 number and 1 special character"
            placeholder="Create a password"
            className="w-full rounded-md border border-gray-300 px-4 py-2.5 outline-none focus:ring-2 focus:ring-sky-500" />
            <p className="text-xs text-gray-500 mt-1"> Must contain at least 1 number and 1 special character. </p> </div>

          {/* Phone number*/}
          <div>
            <label
              htmlFor="phone_number"
              className="block text-sm font-medium text-gray-700 mb-2">Phone Number</label>

            <input
              id="phone_number"
              type="tel"
              name="phone_number"
              required
              placeholder="Enter your phone number"
              className="w-full rounded-md border border-gray-300 px-4 py-2.5 outline-none focus:ring-2 focus:ring-sky-500"
            />
          </div>

          {/* calls add address component */}
          <AddAddress
            address={address}
            onChange={setAddress}
          />

          <button
            type="submit"
            className="w-full bg-darkText text-white py-2.5 rounded-md font-medium hover:bg-gray-800 transition"> Register </button>

        </form>

        {/* Login redirect */}
        <div className="text-center mt-6">
          <p className="text-sm text-gray-500">
            Already have an account - {" "}

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