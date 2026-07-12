import sharp from 'sharp';
import { readdir, mkdir } from 'node:fs/promises';
import { join, dirname, basename } from 'node:path';
import { fileURLToPath } from 'node:url';
const root = fileURLToPath(new URL('../assets/', import.meta.url));
async function walk(dir){ return (await Promise.all((await readdir(dir,{withFileTypes:true})).map(e=>e.isDirectory()?walk(join(dir,e.name)):join(dir,e.name)))).flat(); }
const files=(await walk(root)).filter(f=>f.endsWith('.svg'));
for(const f of files){
  const meta=await sharp(f).metadata();
  for(const scale of [1,2,3]){
    const base=f.slice(0,-4)+`@${scale}x`;
    const pipe=sharp(f,{density:72*scale}).resize(Math.round(meta.width*scale),Math.round(meta.height*scale));
    await pipe.clone().png({compressionLevel:9}).toFile(base+'.png');
    await pipe.clone().webp({lossless:true,effort:6}).toFile(base+'.webp');
  }
}
const launcher=join(root,'icon','icon-launcher-legacy.svg');
for(const [density,size] of [['mdpi',48],['hdpi',72],['xhdpi',96],['xxhdpi',144],['xxxhdpi',192]]){
  const out=join(root,'icon','android',density,'ic-launcher.png'); await mkdir(dirname(out),{recursive:true}); await sharp(launcher).resize(size,size).png().toFile(out);
}
console.log(`Rasterized ${files.length} SVG files`);
