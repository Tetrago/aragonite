#ifndef ARAGONITE_WINDOW_HPP
#define ARAGONITE_WINDOW_HPP

#include <memory>
#include <string>

namespace ar
{
	class Window
	{
	public:
		Window(int width, int height, const std::string& title);
		~Window() noexcept;

		Window(const Window&)            = delete;
		Window& operator=(const Window&) = delete;
		Window(Window&& other) noexcept;
		Window& operator=(Window&& other) noexcept;

	private:
		struct Impl;
		std::unique_ptr<Impl> impl_;
	};
} // namespace ar

#endif
