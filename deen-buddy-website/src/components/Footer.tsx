import Link from 'next/link'

export default function Footer() {
  return (
    <footer className="bg-gray-100 border-t">
      <div className="max-w-6xl mx-auto px-4 py-6">
        <div className="flex flex-col md:flex-row justify-between items-center">
          <p className="text-gray-600 text-sm mb-4 md:mb-0">
            © 2025 myDeen. All rights reserved.
          </p>
          <div className="flex space-x-6">
            <Link href="/privacy" className="text-gray-600 hover:text-green-700 text-sm transition-colors">
              Privacy Policy
            </Link>
            <Link href="/terms" className="text-gray-600 hover:text-green-700 text-sm transition-colors">
              Terms of Service
            </Link>
            <Link href="/support" className="text-gray-600 hover:text-green-700 text-sm transition-colors">
              Support
            </Link>
          </div>
        </div>
      </div>
    </footer>
  )
}