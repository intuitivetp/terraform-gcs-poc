import google.generativeai as genai
import os, glob, textwrap

genai.configure(api_key=os.environ['GEMINI_API_KEY'])

# Read failing log and current tests
log_path = 'tests/test_output.log'
log_text = open(log_path, 'r', errors='ignore').read() if os.path.exists(log_path) else ''

file_paths = sorted(glob.glob('tests/*.go'))
files_blob = []
total_chars = 0
for p in file_paths:
  src = open(p, 'r', errors='ignore').read()
  # keep context reasonable (~8k)
  if total_chars + len(src) > 8000:
    continue
  total_chars += len(src)
  files_blob.append(f"===FILE: {p}===\n{src}")

files_joined = "\n\n".join(files_blob)
prompt_template = """
You are an expert in fixing Terratest (Go) tests for Terraform on GCP.

- The following is the failing test log (trimmed). Identify concrete root causes and propose minimal edits.
- Only fix issues that clearly cause the failures (e.g., wrong variables passed to module, missing defer Destroy, wrong assertions, wrong module vars).
- Do NOT introduce new dependencies. Keep tests simple and deterministic.
- Output ONLY the fully-corrected file contents for the files that require changes, using this exact format:
  ===FILE: tests/<filename>.go===\n<corrected content>
- If no change is needed for a file, do not output it.

FAIL LOG (trimmed):
{log_snip}

CURRENT TEST FILES (trimmed):
{files_blob}
"""
prompt = prompt_template.format(log_snip=log_text[:6000], files_blob=files_joined)

model = genai.GenerativeModel('gemini-2.0-flash')
resp = model.generate_content(prompt, generation_config={'temperature': 0.2, 'max_output_tokens': 2048})
text = resp.text or ''

# Parse files from response
applied = 0
current_file = None
buffer = []
for line in text.split('\n'):
  if line.startswith('===FILE:') and line.endswith('==='):
    if current_file and buffer:
      with open(current_file, 'w') as f:
        f.write('\n'.join(buffer).rstrip() + '\n')
      applied += 1
    current_file = line.split('===FILE:')[1].split('===')[0].strip()
    buffer = []
  elif current_file:
    buffer.append(line)
if current_file and buffer:
  with open(current_file, 'w') as f:
    f.write('\n'.join(buffer).rstrip() + '\n')
  applied += 1

print(f"Applied fixes to {applied} files.")
if applied == 0:
  print('No changes suggested by Gemini.')
