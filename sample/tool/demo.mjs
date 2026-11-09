// 在真实 Chrome 里验证 Playground，并录制 README 用的演示 GIF 和截图
//
// 用法（在 sample/tool 下）：
//   flutter build web --release    # 在 sample/ 下执行，必须是根路径构建（不加 --base-href）
//   npm ci
//   npm run demo                   # 验证 + 录制，产物在 out/
//   npm run demo -- --update       # 同上，并覆盖仓库的 screenshot/
//
// 依赖：系统安装的 Google Chrome 和 ffmpeg。
// 1. verify：逐项功能断言，生成的代码通过「复制 → 读剪贴板」拿到，不依赖界面渲染
// 2. record：按演示脚本操作，后台循环截视口当录屏帧（CDP screencast 在 headless 下只截到 713px 高），
//    记下时间戳，ffmpeg 按真实时长合成
// 3. shots：2x 高清截图，浅色 / 深色 / 手机窄屏
import { chromium } from 'playwright-core';
import { spawnSync } from 'node:child_process';
import { copyFileSync, existsSync, mkdirSync, readFileSync, rmSync, writeFileSync } from 'node:fs';
import { createServer } from 'node:http';
import { extname, join, normalize } from 'node:path';

const tool = new URL('.', import.meta.url).pathname;
const webDir = join(tool, '../build/web');
const screenshotDir = join(tool, '../../screenshot');
const out = join(tool, 'out/');
const shots = join(out, 'shots/');
const frames = join(out, 'frames/');
const update = process.argv.includes('--update');
const W = 1280, H = 800;

const index = join(webDir, 'index.html');
if (!existsSync(index) || !readFileSync(index, 'utf8').includes('<base href="/">')) {
  console.error('E_BUILD: sample/build/web 不存在或不是根路径构建，先在 sample/ 下执行 flutter build web --release');
  process.exit(2);
}

// 静态服务 build/web，端口由系统分配
const types = { '.html': 'text/html', '.js': 'text/javascript', '.mjs': 'text/javascript', '.json': 'application/json', '.wasm': 'application/wasm', '.png': 'image/png', '.ttf': 'font/ttf', '.otf': 'font/otf', '.txt': 'text/plain', '.bin': 'application/octet-stream', '.frag': 'application/octet-stream' };
const server = createServer((req, res) => {
  const path = normalize(decodeURIComponent(new URL(req.url, 'http://x').pathname)).replace(/^(\.\.[/\\])+/, '');
  const file = join(webDir, path.endsWith('/') ? path + 'index.html' : path);
  if (!file.startsWith(webDir) || !existsSync(file)) {
    res.writeHead(404).end();
    return;
  }
  res.writeHead(200, { 'content-type': types[extname(file)] ?? 'application/octet-stream' }).end(readFileSync(file));
});
await new Promise((resolve) => server.listen(0, '127.0.0.1', resolve));
const BASE = `http://127.0.0.1:${server.address().port}/`;

rmSync(out, { recursive: true, force: true });
mkdirSync(shots, { recursive: true });
mkdirSync(frames, { recursive: true });

const browser = await chromium.launch({ channel: 'chrome', headless: true });
const errors = [];
const results = [];

function check(name, ok, detail = '') {
  results.push(ok);
  console.log(ok ? 'PASS' : 'FAIL', name, ok ? '' : detail);
}

async function open(options) {
  const ctx = await browser.newContext(options);
  await ctx.grantPermissions(['clipboard-read', 'clipboard-write'], { origin: BASE });
  const page = await ctx.newPage();
  page.on('console', (m) => m.type() === 'error' && errors.push(m.text()));
  page.on('pageerror', (e) => errors.push(String(e)));
  await page.goto(BASE);
  await page.waitForSelector('flt-semantics[role="button"]', { timeout: 30000 });
  await page.waitForTimeout(800);
  return { ctx, page };
}

// 无障碍树里的全部文字（标签 + 文本），用来断言界面上可见的状态
const screenText = (page) =>
  page.$$eval('flt-semantics', (els) => els.map((e) => (e.getAttribute('aria-label') ?? '') + ' ' + e.textContent).join('\n'));
const hasText = async (page, s) => (await screenText(page)).includes(s);
const button = (page, label) =>
  page.locator(`flt-semantics[role="button"][aria-label="${label}"]`).or(page.locator('flt-semantics[role="button"]', { hasText: label })).first();
const jsonInput = (page) => page.locator('textarea').first();
const nameInput = (page) => page.locator('input').first();

async function click(page, label, wait = 900) {
  await button(page, label).click();
  await page.waitForTimeout(wait);
}

// 点复制，从剪贴板读回生成的代码
async function copiedCode(page) {
  await page.evaluate(() => navigator.clipboard.writeText(''));
  await click(page, 'Copy', 300);
  return page.evaluate(() => navigator.clipboard.readText());
}

async function breakJson(page) {
  await jsonInput(page).click({ position: { x: 300, y: 200 } });
  await page.keyboard.press('Meta+ArrowDown');
  await page.waitForTimeout(300);
  await page.keyboard.press('Backspace');
}

async function setName(page, name, delay = 0) {
  await nameInput(page).click();
  await page.keyboard.press('Meta+A');
  await page.keyboard.type(name, { delay });
}

// ---------- 1. verify ----------
{
  const { ctx, page } = await open({ viewport: { width: W, height: H }, colorScheme: 'light' });
  let code = await copiedCode(page);
  check('launch: Object preset -> User + Address', code.includes('class User {') && code.includes('class Address {'), code.slice(0, 200));
  check('launch: null-safe final fields', code.includes('final int? id;') && code.includes('final List<String>? tags;'));
  check('launch: double field tolerates int', code.includes("(json['score'] as num?)?.toDouble()"));
  check('launch: stats + Valid Dart badge', (await hasText(page, '2 classes · 9 fields')) && (await hasText(page, 'Valid Dart')));
  check('copy: button shows Copied', await hasText(page, 'Copied'));

  await click(page, 'Array');
  code = await copiedCode(page);
  check('Array: list decoder/encoder', code.includes('List<Products> productsFromJson(String str)') && code.includes('String productsToJson(List<Products> data)'));

  await click(page, 'Nested');
  code = await copiedCode(page);
  check('Nested: four classes', ['class Order {', 'class Customer {', 'class Contact {', 'class Items {'].every((c) => code.includes(c)));
  check('Nested: empty array -> List<dynamic>', code.includes('final List<dynamic>? coupons;'));
  check('Nested: stats', await hasText(page, '4 classes'));

  await click(page, 'Tricky keys');
  code = await copiedCode(page);
  check('Tricky keys: user-name -> userName', code.includes('final String? userName;') && code.includes("json['user-name']"));
  check("Tricky keys: class -> class_, 1st -> n1st, _id -> id, it's -> itS", ['class_;', 'n1st;', 'final int? id;', 'itS;', "json['it\\'s']"].every((c) => code.includes(c)));
  check('Tricky keys: stats count 7 fields', await hasText(page, '1 class · 7 fields'));
  check('Tricky keys: $ref kept and escaped', code.includes('final String? $ref;') && code.includes("json['\\$ref']"));

  await setName(page, 'profile');
  await page.waitForTimeout(600);
  code = await copiedCode(page);
  check('class name: renamed to Profile', code.includes('class Profile {') && code.includes('Profile profileFromJson('));

  await setName(page, '1st');
  await page.waitForTimeout(600);
  check('bad class name: Syntax error badge', await hasText(page, 'Syntax error'));
  check('bad class name: E_DART_SYNTAX card', await hasText(page, 'E_DART_SYNTAX'));
  await setName(page, 'item');
  await page.waitForTimeout(600);

  await breakJson(page);
  await page.waitForTimeout(600);
  check('invalid json: E_JSON + waiting hint', (await hasText(page, 'E_JSON')) && (await hasText(page, 'Waiting for valid JSON')));
  check('invalid json: Copy disabled', await button(page, 'Copy').evaluate((e) => e.getAttribute('aria-disabled') === 'true' || e.hasAttribute('disabled')));
  await page.keyboard.type('}');
  await page.waitForTimeout(600);
  check('fixed json: Valid JSON again', (await hasText(page, 'Valid JSON')) && !(await hasText(page, 'Waiting for valid JSON')));

  await page.keyboard.press('Meta+A');
  await page.keyboard.type('42');
  await page.waitForTimeout(600);
  check('primitive root: E_ROOT', await hasText(page, 'E_ROOT'));
  await page.keyboard.press('Meta+A');
  await page.keyboard.type('{"a":{"b":[1,2]}}');
  await click(page, 'Format', 600);
  // 失焦的 textarea 不再同步 DOM 值，重新聚焦后再读
  await jsonInput(page).click({ position: { x: 300, y: 300 } });
  await page.waitForTimeout(500);
  check('format: json re-indented', (await jsonInput(page).inputValue()).includes('\n  "a": {\n    "b": [\n'));

  await click(page, 'Dark mode', 600);
  check('theme: dark (toggle reads Light mode)', await hasText(page, 'Light mode'));
  await ctx.close();
}

// ---------- 2. record ----------
{
  const { ctx, page } = await open({ viewport: { width: W, height: H }, colorScheme: 'light' });
  const list = [];
  let recording = true;
  const recorder = (async () => {
    while (recording) {
      const buf = await page.screenshot({ type: 'jpeg', quality: 92 });
      const file = `f${String(list.length).padStart(5, '0')}.jpg`;
      writeFileSync(frames + file, buf);
      list.push([file, Date.now() / 1000]);
    }
  })();
  const rest = () => page.mouse.move(W - 40, H - 20);
  await rest();
  await page.waitForTimeout(1800);

  // 代码区往下滚，展示 fromJson / toJson，再滚回来
  await page.mouse.move(930, 520);
  for (let i = 0; i < 6; i++) { await page.mouse.wheel(0, 90); await page.waitForTimeout(60); }
  await page.waitForTimeout(1200);
  for (let i = 0; i < 6; i++) { await page.mouse.wheel(0, -90); await page.waitForTimeout(60); }
  await page.waitForTimeout(500);

  await click(page, 'Nested', 2000);
  await click(page, 'Tricky keys', 2200);
  await setName(page, 'profile', 120);
  await page.waitForTimeout(1300);
  await breakJson(page);
  await page.waitForTimeout(1800);
  await page.keyboard.type('}');
  await page.waitForTimeout(1300);
  await click(page, 'Copy', 1700);
  await click(page, 'Dark mode', 300);
  await rest();
  await page.waitForTimeout(1200);
  await click(page, 'Array', 300);
  await rest();
  await page.waitForTimeout(1900);
  check('record: finished in dark mode', await hasText(page, 'Light mode'));

  recording = false;
  await recorder;
  // ffmpeg concat 清单：每帧显示到下一帧出现为止，最后一帧停 1.5 秒
  const end = list.at(-1)[1] + 1.5;
  const lines = list.map(([f, t], i) => `file '${frames}${f}'\nduration ${((list[i + 1]?.[1] ?? end) - t).toFixed(3)}`);
  writeFileSync(out + 'frames.txt', lines.join('\n') + `\nfile '${frames}${list.at(-1)[0]}'\n`);
  console.log('frames:', list.length, 'seconds:', (end - list[0][1]).toFixed(1));
  await ctx.close();
}

// ---------- 3. shots ----------
for (const scheme of ['light', 'dark']) {
  const { ctx, page } = await open({ viewport: { width: W, height: H }, deviceScaleFactor: 2, colorScheme: scheme });
  await page.mouse.move(W - 5, H - 5);
  await page.screenshot({ path: shots + `${scheme}_object.png` });
  await click(page, 'Nested', 700);
  await page.screenshot({ path: shots + `${scheme}_nested.png` });
  await click(page, 'Tricky keys', 700);
  await page.screenshot({ path: shots + `${scheme}_tricky.png` });
  await breakJson(page);
  await page.waitForTimeout(700);
  await page.mouse.move(W - 5, H - 5);
  await page.screenshot({ path: shots + `${scheme}_error.png` });
  await ctx.close();
}
{
  const { ctx, page } = await open({ viewport: { width: 390, height: 844 }, deviceScaleFactor: 3, colorScheme: 'light', isMobile: true, hasTouch: true });
  check('mobile: renders with Copy button', await hasText(page, 'Copy'));
  await page.screenshot({ path: shots + 'mobile.png' });
  await ctx.close();
}

await browser.close();
server.close();

// ---------- 4. 合成视频和 GIF ----------
function ffmpeg(args) {
  const r = spawnSync('ffmpeg', ['-y', '-loglevel', 'error', ...args], { stdio: 'inherit' });
  if (r.status !== 0) throw new Error(`E_FFMPEG: ffmpeg exited with ${r.status ?? r.error}`);
}
ffmpeg(['-f', 'concat', '-safe', '0', '-i', out + 'frames.txt', '-vf', 'fps=30,format=yuv420p', '-c:v', 'libx264', '-crf', '18', '-movflags', '+faststart', out + 'demo.mp4']);
ffmpeg(['-i', out + 'demo.mp4', '-vf', 'fps=12,scale=960:-1:flags=lanczos,split[a][b];[a]palettegen=max_colors=128:stats_mode=diff[p];[b][p]paletteuse=dither=bayer:bayer_scale=4:diff_mode=rectangle', out + 'demo.gif']);
rmSync(frames, { recursive: true, force: true });
rmSync(out + 'frames.txt', { force: true });

console.log('console errors:', JSON.stringify(errors));
const failed = results.filter((ok) => !ok).length;
console.log(`${results.length - failed}/${results.length} checks passed`);
if (failed || errors.length) process.exit(1);

// README 引用的文件名 ← 本次产物
if (update) {
  const map = {
    'demo.gif': out + 'demo.gif',
    'object.png': shots + 'light_object.png',
    'nested_dark.png': shots + 'dark_nested.png',
    'tricky_keys.png': shots + 'light_tricky.png',
    'invalid_json.png': shots + 'dark_error.png',
    'mobile.png': shots + 'mobile.png',
  };
  for (const [name, src] of Object.entries(map)) copyFileSync(src, join(screenshotDir, name));
  console.log('updated', Object.keys(map).length, 'files in screenshot/');
}
