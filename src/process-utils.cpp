#include "process-utils.hpp"

#include <unordered_map>
#include <tlhelp32.h>
#include <wil/resource.h>

namespace ProcessUtils {

static std::unordered_map<DWORD, DWORD> GetProcessParents(const std::set<DWORD> &pids)
{
	wil::unique_handle handle;
	*handle.put() = CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);

	PROCESSENTRY32W info;
	info.dwSize = sizeof(PROCESSENTRY32W);

	bool ret = Process32FirstW(handle.get(), &info);

	std::unordered_map<DWORD, DWORD> parent_map;
	while (ret) {
		if (pids.contains(info.th32ProcessID))
			parent_map[info.th32ProcessID] = info.th32ParentProcessID;

		ret = Process32NextW(handle.get(), &info);
	}

	for (auto pid : pids) {
		if (parent_map.contains(pid))
			continue;

		parent_map[pid] = -1;
	}

	return parent_map;
}

std::set<DWORD> DeDuplicateCaptureList(const std::set<DWORD> &pids,
				       const std::set<DWORD> &exclude_pids)
{
	std::set<DWORD> all_pids = pids;
	all_pids.insert(exclude_pids.begin(), exclude_pids.end());

	auto parents = GetProcessParents(all_pids);

	std::set<DWORD> uncaptured_pids = pids;
	for (auto pid : exclude_pids)
		uncaptured_pids.erase(parents[pid]);

	std::set<DWORD> explicitly_captured_pids;
	std::set<DWORD> implicitly_captured_pids;

	while (uncaptured_pids.size() > 0) {
		for (auto pid : uncaptured_pids) {
			if (uncaptured_pids.contains(parents[pid]))
				continue;

			explicitly_captured_pids.insert(pid);
		}

		for (auto pid : explicitly_captured_pids)
			uncaptured_pids.erase(pid);

		auto iter = uncaptured_pids.begin();
		while (iter != uncaptured_pids.end()) {
			if (!explicitly_captured_pids.contains(parents[*iter]))
			{
				++iter;
				continue;
			}
			implicitly_captured_pids.insert(*iter);
			iter = uncaptured_pids.erase(iter);
		}
	}

	return explicitly_captured_pids;
}

}
