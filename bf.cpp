#include <cstdio>
#include <unistd.h>
#include <vector>
#include <cstdint>
#include <iostream>
#include <istream>
#include <ostream>
#include <iterator>
#include <stack>
#include <cstring>

// #define DEBUG

#ifdef DEBUG
#define debug(fmt, ...) printf("[DEBUG] " fmt, __VA_ARGS__);
#else
#define debug(fmt, ...)
#endif

using byte = uint8_t;

std::string get_input() {
	std::cin >> std::noskipws;
	std::istream_iterator<char> it(std::cin);
	std::istream_iterator<char> end;
	return std::string(it, end);
}

void brainfuck_run(const std::string& input) {
	debug("Input: %s\n", input.c_str());

	// http://www.muppetlabs.com/~breadbox/bf/
	byte stack[30000] = { 0 };
	byte* sp = &stack[0];

	std::stack<int> jump_back;
	int ignore_until_close_bracket = 0;

	size_t i = 0;
	while (i < input.size()) {
		char c = input[i];

		if (ignore_until_close_bracket) {
			if (c == '[')
				ignore_until_close_bracket++;
			else if (c == ']')
				ignore_until_close_bracket--;

			i++;
			continue;
		}

		switch (c) {
			case '<':
				sp--;
				break;
			case '>':
				sp++;
				break;
			case '+':
				(*sp)++;
				break;
			case '-':
				(*sp)--;
				break;
			case '.':
				putchar(*sp);
				break;
			case ',':
				*sp = getchar();
				break;
			case '[':
				if (!*sp)
					ignore_until_close_bracket++;
				else
					jump_back.push(i);
				break;
			case ']':
				i = jump_back.top();
				jump_back.pop();
				debug("-> jumping back to %d\n", i);
				break;
		}

		if (strchr("+-[]<>,.", c) != NULL) {
			debug("state after %c: "
				  "sp=%d *sp=%d i=%d brackets: %d (next jump: %d)\n",
				  c, sp - stack, *sp, i, ignore_until_close_bracket,
				  jump_back.empty() ? -1 : jump_back.top());
		}

		if (c != ']')
			i++;
	}
}

int main() {
	brainfuck_run(get_input());
	return 0;
}
