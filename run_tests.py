import subprocess
import filecmp
import os
import time
import concurrent.futures

def remove_ext(filename):
    return os.path.splitext(filename)[0]

def compile(filenames):
    jar = os.path.join('..', 'sleec.jar')
    assert(os.path.isfile(jar))
    sleec = [os.path.join('src', f + '.sleec') for f in filenames]
    with open(os.path.join('log', 'compilation.log'), 'w+') as f:
        print('compiling')
        result = subprocess.run(['java', '-jar', jar, *sleec],
                                shell = True,
                                stdout = f,
                                stderr = f)
    return result.returncode == 0

def validate(filename):
    start = time.time()
    csp = os.path.join('src-gen', filename + '.csp')
    expected = os.path.join('expected', filename + '.csp')
    result = {'name': filename}
    with open(os.path.join('log', filename + '.validation.log'), 'w+') as f:
        print(f'validating {filename}\n', end='')
        output = subprocess.run(['refines', '--typecheck', csp],
                                shell = True,
                                stdout = f,
                                stderr = f)
    result['validated'] = output.returncode == 0
    result['checked'] = result['validated'] and filecmp.cmp(csp, expected)
    result['time'] = time.time() - start
    return result

def main():
    start = time.time()
    os.chdir(os.path.dirname(__file__))
    os.chdir('circus.robocalc.sleec.runtime')
    if not os.path.exists('log'):
        os.mkdir('log')

    filenames = [remove_ext(f) for f in os.listdir('src') if '.sleec' in f]

    if not compile(filenames):
        print('compilation failed')
        exit(1)

    print('------------------------------')

    with concurrent.futures.ThreadPoolExecutor() as executor:
        futures = [executor.submit(validate, f) for f in filenames]

    print('------------------------------')

    validation_results = [f.result() for f in futures]
    num_failed = 0
    for r in validation_results:
        if not r['validated']:
            print(r['name'], 'failed validation')
        elif not r['checked']:
            print(r['name'], 'didn\'t match expected output')
        else:
            print(r['name'], 'passed in %.3f seconds' % r['time'])
            continue
        num_failed += 1

    print('------------------------------')

    if num_failed:
        print(num_failed, 'tests failed')
    else:
        print('testing completed in %.3f seconds' % (time.time() - start))
    exit(num_failed != 0)

if __name__ == '__main__':
    main()
