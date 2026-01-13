#pragma once

#include <set>
#include <windows.h>

namespace ProcessUtils {

std::set<DWORD> DeDuplicateCaptureList(const std::set<DWORD> &pids,
				       const std::set<DWORD> &exclude_pids = std::set<DWORD>());

}
