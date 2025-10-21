'use client'

import Link from 'next/link'
import { useState } from 'react'

export default function Navigation() {
  const [isOpen, setIsOpen] = useState(false)

  return (
    <nav className="bg-white shadow-md">
      <div className="max-w-6xl mx-auto px-4">
        <div className="flex justify-between items-center h-16">
          <Link href="/" className="flex items-center">
            <span className="text-xl font-bold text-green-700">myDeen</span>
            <span className="text-xl text-gray-600 ml-2">Legal</span>
          </Link>

          <div className="hidden md:flex space-x-8">
            <Link
              href="/"
              className="text-gray-700 hover:text-green-700 transition-colors"
            >
              Home
            </Link>
            <Link
              href="/privacy"
              className="text-gray-700 hover:text-green-700 transition-colors"
            >
              Privacy Policy
            </Link>
            <Link
              href="/terms"
              className="text-gray-700 hover:text-green-700 transition-colors"
            >
              Terms of Service
            </Link>
            <Link
              href="/support"
              className="text-gray-700 hover:text-green-700 transition-colors"
            >
              Support
            </Link>
          </div>

          <button
            className="md:hidden"
            onClick={() => setIsOpen(!isOpen)}
            aria-label="Toggle menu"
          >
            <svg
              className="w-6 h-6"
              fill="none"
              stroke="currentColor"
              viewBox="0 0 24 24"
            >
              {isOpen ? (
                <path
                  strokeLinecap="round"
                  strokeLinejoin="round"
                  strokeWidth={2}
                  d="M6 18L18 6M6 6l12 12"
                />
              ) : (
                <path
                  strokeLinecap="round"
                  strokeLinejoin="round"
                  strokeWidth={2}
                  d="M4 6h16M4 12h16M4 18h16"
                />
              )}
            </svg>
          </button>
        </div>

        {isOpen && (
          <div className="md:hidden pb-4">
            <Link
              href="/"
              className="block py-2 text-gray-700 hover:text-green-700 transition-colors"
              onClick={() => setIsOpen(false)}
            >
              Home
            </Link>
            <Link
              href="/privacy"
              className="block py-2 text-gray-700 hover:text-green-700 transition-colors"
              onClick={() => setIsOpen(false)}
            >
              Privacy Policy
            </Link>
            <Link
              href="/terms"
              className="block py-2 text-gray-700 hover:text-green-700 transition-colors"
              onClick={() => setIsOpen(false)}
            >
              Terms of Service
            </Link>
            <Link
              href="/support"
              className="block py-2 text-gray-700 hover:text-green-700 transition-colors"
              onClick={() => setIsOpen(false)}
            >
              Support
            </Link>
          </div>
        )}
      </div>
    </nav>
  )
}