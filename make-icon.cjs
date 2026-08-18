// Render the DeepSeek Harness favicon glyph onto a blue rounded tile
// and pack it into a multi-size .ico for the desktop shortcut.
const sharp = require('C:/Users/Kevincat/.dsh/profiles/node_modules/sharp');
const fs = require('fs');

const SRC = 'C:/Users/Kevincat/AppData/Local/npm-cache/_npx/1e7f6d9597241db0/node_modules/@deepseek-ai/dsh-web-frontend/dist/favicon.svg';
const OUT = 'C:/Users/Kevincat/DeepSeekHarness';

const svgText = fs.readFileSync(SRC, 'utf8');
const dMatch = svgText.match(/d="([^"]+)"/);
if (!dMatch) { console.error('no path d found in favicon.svg'); process.exit(1); }
const d = dMatch[1];

const S = 256;
const PAD = 28;
const SCALE = (S - 2 * PAD) / 50; // original viewBox is 50x50

const iconSvg = `<svg xmlns="http://www.w3.org/2000/svg" width="${S}" height="${S}" viewBox="0 0 ${S} ${S}">
<rect width="${S}" height="${S}" rx="${Math.round(S * 0.22)}" fill="#4D6BFE"/>
<g transform="translate(${PAD} ${PAD}) scale(${SCALE})" fill="#ffffff"><path d="${d}"/></g>
</svg>`;

(async () => {
  const p256 = await sharp(Buffer.from(iconSvg)).resize(S, S).png().toBuffer();
  fs.writeFileSync(OUT + '/icon-256.png', p256);

  const sizes = [16, 24, 32, 48, 64, 128, 256];
  const pngs = [];
  for (const s of sizes) {
    const buf = s === 256 ? p256 : await sharp(p256).resize(s, s).png().toBuffer();
    pngs.push({ s, buf });
  }

  // Pack PNG-compressed entries into a valid .ico
  const count = pngs.length;
  const header = Buffer.alloc(6);
  header.writeUInt16LE(0, 0);          // reserved
  header.writeUInt16LE(1, 2);          // type: icon
  header.writeUInt16LE(count, 4);
  let offset = 6 + 16 * count;
  const entries = [];
  for (const { s, buf } of pngs) {
    const e = Buffer.alloc(16);
    e.writeUInt8(s === 256 ? 0 : s, 0); // width
    e.writeUInt8(s === 256 ? 0 : s, 1); // height
    e.writeUInt8(0, 2);                 // palette
    e.writeUInt8(0, 3);                 // reserved
    e.writeUInt16LE(1, 4);              // planes
    e.writeUInt16LE(32, 6);             // bpp
    e.writeUInt32LE(buf.length, 8);
    e.writeUInt32LE(offset, 12);
    offset += buf.length;
    entries.push(e);
  }
  const ico = Buffer.concat([header, ...entries, ...pngs.map((p) => p.buf)]);
  fs.writeFileSync(OUT + '/DeepSeek-Harness.ico', ico);
  console.log('wrote DeepSeek-Harness.ico (' + ico.length + ' bytes)');
})().catch((e) => { console.error(e); process.exit(1); });
