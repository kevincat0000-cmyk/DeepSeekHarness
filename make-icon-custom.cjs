// Convert the user's chosen image into a rounded, multi-size .ico
// for the DeepSeek Harness desktop shortcut.
const sharp = require('C:/Users/Kevincat/.dsh/profiles/node_modules/sharp');
const fs = require('fs');

const SRC = 'C:/Users/Kevincat/Downloads/《梁圣降级小难梁》扒的一位大佬的图🤣_1_OrbiGet Craft｜灵境山海_来自小红书网页版.jpg';
const OUT = 'C:/Users/Kevincat/DeepSeekHarness/DeepSeek-Harness-custom.ico';

(async () => {
  const img = sharp(SRC);
  const meta = await img.metadata();
  console.log('source:', meta.width + 'x' + meta.height, meta.format);

  const S = 256;
  const R = Math.round(S * 0.18); // corner radius

  // center-crop to square, resize to 256, round the corners
  const base = await img
    .rotate() // honor EXIF orientation
    .resize(S, S, { fit: 'cover' })
    .composite([{
      input: Buffer.from(`<svg width="${S}" height="${S}"><rect x="0" y="0" width="${S}" height="${S}" rx="${R}" ry="${R}"/></svg>`),
      blend: 'dest-in'
    }])
    .png()
    .toBuffer();

  const sizes = [16, 24, 32, 48, 64, 128, 256];
  const pngs = [];
  for (const s of sizes) {
    const buf = s === S ? base : await sharp(base).resize(s, s).png().toBuffer();
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
  fs.writeFileSync(OUT, Buffer.concat([header, ...entries, ...pngs.map((p) => p.buf)]));
  console.log('wrote', OUT);
})().catch((e) => { console.error(e); process.exit(1); });
