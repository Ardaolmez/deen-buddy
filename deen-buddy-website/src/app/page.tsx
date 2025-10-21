import Link from 'next/link'

export default function Home() {
  return (
    <div className="bg-gray-50 min-h-full">
      <div className="max-w-4xl mx-auto px-4 py-16">
        <div className="text-center mb-12">
          <h1 className="text-4xl md:text-5xl font-bold text-gray-900 mb-4">
            myDeen
          </h1>
          <p className="text-xl text-gray-600">
            Your Religious Guide
          </p>
        </div>

        <div className="bg-white rounded-lg shadow-sm p-8 text-center">
          <h2 className="text-2xl font-semibold text-gray-900 mb-6">
            Legal Information
          </h2>
          <p className="text-gray-600 mb-8">
            Access important documents and support for myDeen app
          </p>

          <div className="grid md:grid-cols-3 gap-4">
            <Link
              href="/privacy"
              className="bg-gray-100 hover:bg-gray-200 text-gray-800 py-4 px-6 rounded-lg transition-colors"
            >
              Privacy Policy
            </Link>
            <Link
              href="/terms"
              className="bg-gray-100 hover:bg-gray-200 text-gray-800 py-4 px-6 rounded-lg transition-colors"
            >
              Terms of Service
            </Link>
            <Link
              href="/support"
              className="bg-green-600 hover:bg-green-700 text-white py-4 px-6 rounded-lg transition-colors"
            >
              Contact Support
            </Link>
          </div>
        </div>
      </div>
    </div>
  )
}