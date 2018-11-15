import re
import os
import fnmatch
try:
    for root, dirnames, filenames in os.walk(os.path.dirname(os.path.realpath(__file__))):
        for filename in fnmatch.filter(filenames, '*.txt'):
            filename = os.path.join(root, filename)
            f = open(filename, 'r')
            print '[-] Scanning', os.path.basename(filename), '...'
            lines = f.readlines()
            content = ''.join(lines)
            pattern = re.compile(r":\s(\d{2})\s")
            words = pattern.findall(content)
            words = map(str.strip, words)
            words = set(words)
            words = sorted(words)
            for word in words:
                print '[%-3s]\t%-4d time(s).'%(word, content.count(word))
except Exception as e:
    print '[-] Something went wrong: ', e.message
raw_input('')