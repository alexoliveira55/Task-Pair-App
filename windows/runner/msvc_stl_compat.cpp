// msvc_stl_compat.cpp
//
// Provides stubs for MSVC STL vectorized algorithm intrinsics that were
// introduced in Visual Studio 2022 17.5+. The prebuilt Firebase C++ SDK
// (specifically the bundled gRPC component inside firebase_firestore.lib)
// was compiled against a newer MSVC that emits calls to these functions.
// If the local MSVC runtime libraries are older, the linker cannot resolve
// them. The stubs below are functionally equivalent scalar fallbacks.

#include <cstddef>
#include <cstdint>

extern "C" {

// Scalar fallback for the vectorized std::min_element over 8-byte elements.
// MSVC STL calls this when min_element is used with the default operator< on
// an 8-byte arithmetic type (e.g. int64_t, uint64_t, double, pointer).
// The pointers are offset by sizeof(element) = 8 bytes per step.
__declspec(noinline) const void* __cdecl __std_min_element_8(
    const void* const _First, const void* const _Last) noexcept
{
    const auto* first = static_cast<const std::int64_t*>(_First);
    const auto* last  = static_cast<const std::int64_t*>(_Last);
    if (first == last) {
        return _First;
    }
    const auto* min_ptr = first;
    for (const auto* it = first + 1; it != last; ++it) {
        if (*it < *min_ptr) {
            min_ptr = it;
        }
    }
    return static_cast<const void*>(min_ptr);
}

} // extern "C"
