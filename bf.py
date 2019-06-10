import sys

class lifo_queue(object):
	_data = []

	def top(self):
		return self._data[-1]

	def empty(self):
		return len(self._data) == 0

	def pop(self):
		self._data = self._data[0:-1]

	def push(self, arg):
		self._data.append(arg)

	def getpop(self):
		r = self.top()
		self.pop()
		return r

def brainfuck_run(code):
	stack = [0] * 30000
	sp = 0

	jump_back = lifo_queue()
	bracket_ignore = 0

	i = 0
	while i < len(code):
		c = code[i]

		if bracket_ignore:
			if c == '[':
				bracket_ignore += 1
			elif c == ']':
				bracket_ignore -= 1

			i += 1
			continue

		if c == '<':
			sp -= 1
		elif c == '>':
			sp += 1
		elif c == '+':
			stack[sp] += 1
		elif c == '-':
			stack[sp] -= 1
		elif c == '.':
			sys.stdout.write("%c" % stack[sp])
		elif c == ',':
			stack[sp] = sys.stdin.read(1)
		elif c == '[':
			if not stack[sp]:
				bracket_ignore += 1
			else:
				jump_back.push(i)
		elif c == ']':
			i = jump_back.getpop()

		if c != ']':
			i += 1


def get_input(argv):
	if len(sys.argv) > 1:
		return open(sys.argv[1], 'r').read()
	else:
		return sys.stdin.read()

def main(argv):
	brainfuck_run(get_input(argv))

if __name__ == '__main__':
	main(sys.argv)
