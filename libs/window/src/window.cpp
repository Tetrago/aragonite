#include "window.hpp"

#include <mutex>
#include <stdexcept>
#include <utility>

#define GLFW_INCLUDE_NONE
#include <GLFW/glfw3.h>

using ar::Window;

struct Window::Impl
{
	GLFWwindow* handle;
};

namespace
{
	std::mutex mutex;
	unsigned count = 0;
} // namespace

Window::Window(int width, int height, const std::string& title)
    : impl_(std::make_unique<Impl>())
{
	{
		std::lock_guard lock(mutex);

		if (count++ == 0 && !glfwInit())
		{
			throw std::runtime_error("failed to initialize glfw");
		}

		glfwDefaultWindowHints();
		glfwWindowHint(GLFW_RESIZABLE, GLFW_FALSE);

		impl_->handle =
		    glfwCreateWindow(width, height, title.c_str(), NULL, NULL);
	}

	glfwSetWindowUserPointer(impl_->handle, impl_.get());
}

Window::~Window() noexcept
{
	if (impl_)
	{
		glfwDestroyWindow(impl_->handle);

		std::lock_guard lock(mutex);

		if (--count == 0)
		{
			glfwTerminate();
		}
	}
}

Window::Window(Window&& other) noexcept
    : impl_(std::move(other.impl_))
{}

Window& Window::operator=(Window&& other) noexcept
{
	impl_ = std::move(other.impl_);

	return *this;
}
