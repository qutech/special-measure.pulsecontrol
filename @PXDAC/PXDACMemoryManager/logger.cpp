#include "Logger.h"

#include <fstream>
#include <iostream>

#include <iomanip>
#include <ctime>

std::string logger::logPath = "C:\\Users\\Public";
std::ofstream logger::fileStream = std::ofstream(logPath + "\\PXDACMemoryManager_load.log",std::ios_base::out);


void logger::log_message(const time_t& timestamp, const std::string& message)
{
	struct std::tm * ptm = std::localtime(&timestamp);
	logStream() << "[ " << std::put_time(ptm, "%X") << " ]:\t" << message << std::flush;
}