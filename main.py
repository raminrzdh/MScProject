import operator

LOG_ENABLE = False
FILE_NAME = 'result6.vcd'
EXPRESSION = 'tempout inexp tempout - indata 1145324612 / 2 / * indata 1145324612 / * +'
CONDITION_EXPRESSION = 'done 1 != count 0 = bothrdy 1 =  multgo 0 = & & &'
variable_identifier_map = {}
identifier_variable_map = {}
identifier_value_map = {}
count = {}
total_timeslots = 0




def test_conditions(condition, variables_values):
    unary_operators = {'!': operator.not_, '~': operator.invert}
    binary_operators = {'+': operator.add, '-': operator.sub, '*': operator.mul, '/': operator.div, '|': operator.or_,
                        '&': operator.and_, '^': operator.xor, '<': operator.lt, '<=': operator.le, '=': operator.eq,
                        '>': operator.gt, '>=': operator.ge, '!=': operator.ne}
    stack = []
    for element in condition.split():
        if element.isdigit():
            stack.append({element: int(element)})
        elif element.isalnum():
            stack.append({element: variables_values[element]})
        else:
            op = element
            if op in unary_operators:
                op1 = stack.pop()
                op1_symbol = op1.keys()[0]
                op1_value = op1.values()[0]
                value = unary_operators[op](op1_value)
                stack.append({' '.join([op1_symbol, op]): value})
            else:
                op2 = stack.pop()
                op2_symbol = op2.keys()[0]
                op2_value = op2.values()[0]
                op1 = stack.pop()
                op1_symbol = op1.keys()[0]
                op1_value = op1.values()[0]
                try:
                    value = binary_operators[op](op1_value, op2_value)
                except:
                    value = float('Inf')
                stack.append({' '.join([op1_symbol, op2_symbol, op]): value})
    return stack.pop().values()[0]


def expr_count(expression, variables_values):
    unary_operators = {'!': operator.not_, '~': operator.invert}
    binary_operators = {'+': operator.add, '-': operator.sub, '*': operator.mul, '/': operator.div, '|': operator.or_,
                        '&': operator.and_, '^': operator.xor}
    comparison_operators = {'<': operator.lt, '<=': operator.le, '=': operator.eq,
                            '>': operator.gt, '>=': operator.ge, '!=': operator.ne}
    operator_identity_number = {'+': 0, '-': 0, '*': 1, '/': 1, '|': False, '&': True, '^': False}
    operator_index = 1
    stack = []
    for element in expression.split():
        if element.isdigit():
            stack.append({element: int(element)})
        elif element.isalnum():
            stack.append({element: variables_values[element]})
        else:
            op = element
            if op in unary_operators:
                op1 = stack.pop()
                op1_symbol = op1.keys()[0]
                op1_value = op1.values()[0]
                value = unary_operators[op](op1_value)
                stack.append({' '.join([op1_symbol, op]): value})
            else:
                op2 = stack.pop()
                op2_symbol = op2.keys()[0]
                op2_value = op2.values()[0]
                op1 = stack.pop()
                op1_symbol = op1.keys()[0]
                op1_value = op1.values()[0]
                if operator_index not in count:
                    count[operator_index] = dict()
                if op in comparison_operators:
                    value = comparison_operators[op](op1_value, op2_value)
                    if not count[operator_index]:
                        count[operator_index] = {True: 0, False: 0}
                    count[operator_index][value] += 1
                else:
                    if op1_symbol not in count[operator_index]:
                        count[operator_index][op1_symbol] = {operator_identity_number[op]: 0}
                    count[operator_index][op1_symbol][operator_identity_number[op]] += int(
                        op1_value == operator_identity_number[op])
                    if op2_symbol not in count[operator_index]:
                        count[operator_index][op2_symbol] = {operator_identity_number[op]: 0}
                    count[operator_index][op2_symbol][operator_identity_number[op]] += int(
                        op2_value == operator_identity_number[op])
                    try:
                        value = binary_operators[element](op1_value, op2_value)
                    except:
                        value = float('Inf')
                operator_index += 1
                stack.append({' '.join([op1_symbol, op2_symbol, op]): value})


def get_variables_values(variable_identifier_map, identifier_value_map):
    for variable in variable_identifier_map:
        variable_identifier_map[variable].sort(key=lambda x: x[0])
        value = ''
        for bit_num, identifier in variable_identifier_map[variable]:
            value += identifier_value_map[identifier]
        yield variable, value


with open(FILE_NAME) as input_file:
    for i, line in enumerate(input_file):
        if line.startswith('$var wire 1 '):
            elements = map(str.strip, line.split()[3:6])
            identifier, variable = elements[:2]
            if elements[-1] != '$end':
                bit_num = int(elements[-1][1:-1])
            else:
                bit_num = 0
            if variable not in variable_identifier_map:
                variable_identifier_map[variable] = []
            variable_identifier_map[variable] += [(bit_num, identifier)]
            if identifier not in identifier_variable_map:
                identifier_variable_map[identifier] = set()
            identifier_variable_map[identifier].add(variable)
        elif line.startswith('#'):
            time = int(line[1:])
            for line in input_file:
                if line.startswith('$'):
                    continue
                elif line.startswith('#'):
                    new_time = int(line[1:])
                    if LOG_ENABLE: print '[%ld]' % time, '-' * 50
                    variables_values = {}
                    for variable, value in get_variables_values(variable_identifier_map, identifier_value_map):
                        if 'x' not in value:
                            variables_values[variable] = int(value, 2)
                        else:
                            variables_values[variable] = value
                        if LOG_ENABLE: print '%c %-10s %-32s' % (is_changed, wire_name, value)
                    if test_conditions(CONDITION_EXPRESSION, variables_values):
                        total_timeslots += 1
                            expr_count(EXPRESSION,Variable_value)
                            new_time=variable_value[variable]=value
                        expr_count(EXPRESSION, variables_values)
                    time = new_time
                    continue
                identifier = line[1:].strip()
                value = line[0]
                identifier_value_map[identifier] = value

print '-' * 50
print 'Summary'
print 'Test Expression:', CONDITION_EXPRESSION
print 'Expression:', EXPRESSION
print 'Total Timeslots:', total_timeslots
# print '{:<25} {:<20} {:<15}'.format('Expression', 'Value', 'Probability')
# for expression in count.keys():
#     for value in count[expression].keys():
#         print '{:<25} {:<20} {:<15}'.format(expression, str(value) + ': ' + str(count[expression][value]) + ' times',
#                                             float(count[expression][value]) / total_timeslots)
for k, v in count.iteritems():
    print k
    for x, y in v.iteritems():
        print x, y
