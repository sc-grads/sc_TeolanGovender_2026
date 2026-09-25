import { useEffect, useState } from "react";
import { useNavigate } from "react-router-dom";
import { config } from "../../../config";
import AddAddress, { type AddressFormData } from "../profile/AddAddress";

interface Address extends AddressFormData {
  address_id: number;
}

const INITIAL_ADDRESS_STATE: AddressFormData = {
  address_line_1: "",
  address_line_2: "",
  city: "",
  province: "",
  postal_code: "",
};

const AddressManagement = () => {
  const navigate = useNavigate();

  const [addresses, setAddresses] = useState<Address[]>([]);
  const [address, setAddress] = useState<AddressFormData>(INITIAL_ADDRESS_STATE);
  const [editingAddressId, setEditingAddressId] = useState<number | null>(null);
  const [isFormOpen, setIsFormOpen] = useState(false);

  /* function rerieves and sets address */
  const fetchAddresses = async () => {
    const token = localStorage.getItem("access_token");
    const response = await fetch(`${config.baseUrl}/address`,
      {
        headers: {Authorization: `Bearer ${token}`}});

    if (response.ok) {
      setAddresses(await response.json());
    }
  };

  useEffect(() => {
    fetchAddresses();
  }, []);

  /* function to delete address address */
  const deleteAddress = async (addressId: number) => {
    /*if (!window.confirm("Are you sure you want to delete this address?")) {
      return;
    }*/

    const token = localStorage.getItem("access_token");

    const response = await fetch(`${config.baseUrl}/address/${addressId}`, {
      method: "DELETE",
      headers: {
        Authorization: `Bearer ${token}`,
      },
    });

    if (response.ok) {
      setAddresses((prev) => prev.filter((item) => item.address_id !== addressId));
    }
  };

  const startAddingAddress = () => {
    setAddress(INITIAL_ADDRESS_STATE);
    setEditingAddressId(null);
    setIsFormOpen(true);
  };

  const startEditingAddress = (selectedAddress: Address) => {
    setAddress({
      address_line_1: selectedAddress.address_line_1,
      address_line_2: selectedAddress.address_line_2,
      city: selectedAddress.city,
      province: selectedAddress.province,
      postal_code: selectedAddress.postal_code,
    });

    setEditingAddressId(selectedAddress.address_id);
    setIsFormOpen(true);
  };

  const cancelForm = () => {
    setAddress(INITIAL_ADDRESS_STATE);
    setEditingAddressId(null);
    setIsFormOpen(false);
  };

  const handleAddressSubmit = async (e: React.FormEvent<HTMLFormElement>) => {
    e.preventDefault();

    const token = localStorage.getItem("access_token");

    const response = await fetch(
      editingAddressId
        ? `${config.baseUrl}/address/${editingAddressId}`
        : `${config.baseUrl}/address`,
      {
        method: editingAddressId ? "PATCH" : "POST",
        headers: {
          "Content-Type": "application/json",
          Authorization: `Bearer ${token}`,
        },
        body: JSON.stringify(address),
      }
    );

    if (response.ok) {
      await fetchAddresses();
      cancelForm();
    }
  };

  return (
    <div className="mx-auto max-w-2xl p-5">
      <button
        type="button"
        onClick={() => navigate("/profile")}
        className="mb-5 text-sky-600 hover:underline"
      >
        ← Back to Profile
      </button>

      <div className="mb-6 flex items-center justify-between">
        <h1 className="text-2xl font-bold">Manage Addresses</h1>

        {!isFormOpen && (
          <button
            type="button"
            onClick={startAddingAddress}
            className="rounded-md bg-greenText px-4 py-2 font-medium text-white transition hover:bg-skyText"
          >
            Add Address
          </button>
        )}
      </div>

      {/* Conditionally Render Form OR Address List */}
      {isFormOpen ? (
        <div className="mb-6 rounded-lg border p-5">
          <h2 className="mb-5 text-xl font-semibold">
            {editingAddressId !== null ? "Edit Address" : "Add Address"}
          </h2>

          <form onSubmit={handleAddressSubmit} className="space-y-5">
            <AddAddress address={address} onChange={setAddress} />

            <div className="flex gap-3">
              <button
                type="submit"
                className="rounded-md bg-darkText px-4 py-2.5 font-medium text-white transition hover:bg-gray-800"
              >
                {editingAddressId !== null ? "Save Changes" : "Save Address"}
              </button>

              <button
                type="button"
                onClick={cancelForm}
                className="rounded-md border border-gray-300 px-4 py-2.5 transition hover:bg-gray-100"
              >
                Cancel
              </button>
            </div>
          </form>
        </div>
      ) : (
        /* saved addresses list (only shown when form is closed) */
        <div className="space-y-4">
          {addresses.length === 0 ? (
            <p className="text-gray-600">No saved addresses.</p>
          ) : (
            addresses.map((item) => (
              <div key={item.address_id} className="rounded-lg border p-4">
                <p>{item.address_line_1}</p>
                {item.address_line_2 && <p>{item.address_line_2}</p>}
                <p>{item.city}</p>
                <p>{item.province}</p>
                <p>{item.postal_code}</p>

                <div className="mt-3 flex gap-4">
                  <button
                    type="button"
                    onClick={() => startEditingAddress(item)}
                    className="text-sky-600 hover:underline"
                  >
                    Edit
                  </button>

                  <button
                    type="button"
                    onClick={() => deleteAddress(item.address_id)}
                    className="text-red-600 hover:underline"
                  >
                    Remove
                  </button>
                </div>
              </div>
            ))
          )}
        </div>
      )}
    </div>
  );
};

export default AddressManagement;