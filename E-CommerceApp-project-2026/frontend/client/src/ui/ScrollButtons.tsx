//import React from "react";

type ScrollButtonsProps = {
  onLeft: () => void;
  onRight: () => void;
};

const ScrollButtons = ({
  onLeft,
  onRight,
}: ScrollButtonsProps) => {
  return (
    <div className="flex items-center gap-3">
      {/* Left Button */}
      <button
        onClick={onLeft}
        aria-label="Scroll Left"
        className="group flex h-11 w-11 items-center justify-center rounded-full bg-white/90 backdrop-blur-md shadow-md ring-1 ring-gray-200 transition-all duration-200 hover:scale-105 hover:shadow-lg hover:ring-gray-300 active:scale-95"
      >
        <svg
          xmlns="http://www.w3.org/2000/svg"
          className="h-5 w-5 text-gray-700 transition-transform duration-200 group-hover:-translate-x-0.5"
          fill="none"
          viewBox="0 0 24 24"
          stroke="currentColor"
          strokeWidth={2.5}
        >
          <path
            strokeLinecap="round"
            strokeLinejoin="round"
            d="M15 19l-7-7 7-7"
          />
        </svg>
      </button>

      {/* Right Button */}
      <button
        onClick={onRight}
        aria-label="Scroll Right"
        className="group flex h-11 w-11 items-center justify-center rounded-full bg-darkText text-white shadow-md transition-all duration-200 hover:scale-105 hover:shadow-lg active:scale-95"
      >
        <svg
          xmlns="http://www.w3.org/2000/svg"
          className="h-5 w-5 transition-transform duration-200 group-hover:translate-x-0.5"
          fill="none"
          viewBox="0 0 24 24"
          stroke="currentColor"
          strokeWidth={2.5}
        >
          <path
            strokeLinecap="round"
            strokeLinejoin="round"
            d="M9 5l7 7-7 7"
          />
        </svg>
      </button>
    </div>
  );
};

export default ScrollButtons;