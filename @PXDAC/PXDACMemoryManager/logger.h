#pragma once

#include <string>
#include <iostream>
#include <sstream>
#include <fstream>

#include <chrono>


#if defined ( WIN32)
#define DEBUGINFO __FILE__,__LINE__,__FUNCTION__
#else
#define DEBUGINFO __FILE__,__LINE__
#endif

//this macro creates a channel with name _name by forwarding it to log(...)
#define STORE_DEBUG_CHANNEL(_name) \
	template<typename... Args> \
	static void _name(Args&&... args) {	log(std::forward<Args>(args)...); }

//this macro creates an empty channel
#define DUMP_DEBUG_CHANNEL(_name) \
	template<typename... Args> \
	static void _name(Args&&... args) {};


//this class logs all to the logstream with a timestamp
class logger{
private:
	static std::ofstream fileStream;

	static std::ostream& logStream()
	{
		if (fileStream.is_open())
			return fileStream;
		return std::cout;
	};

	//these two functions fill the arguments in the provided outputstream. They are generated at compile time since they are (variadic) template functions.
	template<typename T, typename... Args>
	static void internal_log(std::ostream& out, const T& next, Args&&... remaining)
	{
		out << next;
		internal_log(out,remaining...);
	}
	template<typename T>
	static void internal_log(std::ostream& out, const T& last)
	{
		out << last << "\n";
	}


	//reduce warnings
	static void log_message(const time_t& timestamp, const std::string& message);

public:
	static std::string logPath;

	template<typename... Args>
	static std::string log(Args&&... args)
	{
		const time_t timestamp = std::chrono::system_clock::to_time_t(std::chrono::system_clock::now());
		
		//write the message into this buffer, so the logger mutex lock time is minimized
		std::stringstream logbuffer;
		internal_log(logbuffer, args...);
		
		log_message(timestamp, logbuffer.str());

		return logbuffer.str();
	}


	static void setStreamToFile(const std::string& filename)
	{
		fileStream.close();
		fileStream = std::ofstream(filename.c_str(), std::ios_base::out);
	}
	static void rotateFile()
	{
		static unsigned count = 1;
		setStreamToFile(logPath + "\\PXDACMemoryManager_" + std::to_string(count++) + ".log");
	}
	static void closeLog()
	{
		fileStream.close();
	}
};