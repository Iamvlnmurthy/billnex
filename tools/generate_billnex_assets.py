from pathlib import Path
import io, math
from PIL import Image, ImageDraw, ImageFont

ROOT = Path(__file__).resolve().parents[1] / "assets"
P={"blue":"#146CFF","deep":"#0055D1","navy":"#111C2D","bg":"#F4F6FC","card":"#FFFFFF","soft":"#F0F3FF","green":"#12B76A","greenfill":"#E6F6EE","amber":"#C15700","amberfill":"#FBEEDD","red":"#BA1A1A","outline":"#C2C6D8","dark":"#0B1220","darkcard":"#141D30"}

def esc(s): return s.replace('&','&amp;').replace('<','&lt;')
def svg(w,h,body,bg=None):
    back=f'<rect width="{w}" height="{h}" fill="{bg}"/>' if bg else ''
    return f'''<svg xmlns="http://www.w3.org/2000/svg" width="{w}" height="{h}" viewBox="0 0 {w} {h}"><title>BillNex asset</title><g id="background">{back}</g><g id="artwork" stroke-linecap="round" stroke-linejoin="round">{body}</g></svg>'''
def save(rel, data, scales=(1,2,3), raster=True):
    path=ROOT/rel; path.parent.mkdir(parents=True,exist_ok=True); path.write_text(data,encoding='utf-8')
    # Raster exports are produced by tools/rasterize_assets.mjs (Sharp/libvips).

def receipt_mark(size=512, mono=False, fg_only=False):
    ink="#FFFFFF"; accent=ink if mono else P['green']; sh=P['deep']
    shadow='' if fg_only or mono else f'<path d="M184 118h178v254l-34 34H184z" fill="{sh}" opacity=".38" transform="translate(22 22)"/>'
    return shadow+f'''<path d="M166 104h180v274l-18-12-18 12-18-12-18 12-18-12-18 12-18-12-18 12-18-12-18 12V104z" fill="{ink}"/>
    <path d="M208 164h96M208 204h72" stroke="{P['deep'] if not mono else P['navy']}" stroke-width="16"/>
    <text x="208" y="284" font-family="Inter,Arial,sans-serif" font-size="72" font-weight="700" fill="{P['deep'] if not mono else P['navy']}">₹</text>
    <circle cx="312" cy="306" r="52" fill="{accent}"/><path d="m286 306 18 18 34-38" fill="none" stroke="#FFFFFF" stroke-width="14"/>'''

def icon_assets():
    body=receipt_mark(); legacy=svg(512,512,body,P['blue']); save('icon/icon-launcher-legacy.svg',legacy,(1,2,3))
    save('icon/icon-play-store-512.svg',legacy,(1,),True)
    save('icon/icon-launcher-foreground.svg',svg(512,512,receipt_mark(fg_only=True)),(1,2,3))
    save('icon/icon-launcher-background.svg',svg(512,512,'',P['blue']),(1,2,3))
    save('icon/icon-launcher-monochrome.svg',svg(512,512,receipt_mark(mono=True,fg_only=True)),(1,2,3))
    # Android launcher density exports, exact platform sizes.

def scene(theme,kind,w=640,h=400):
    dark=theme=='dark'; ink='#F4F6FC' if dark else P['navy']; card=P['darkcard'] if dark else P['card']; line='#C2C6D8'; soft='#1B2942' if dark else P['soft']
    base=f'<ellipse cx="320" cy="344" rx="216" ry="22" fill="{P["deep"]}" opacity=".10"/>'
    if kind=='business':
        art=f'''<path d="M144 168h352l-24-72H168z" fill="{P['blue']}"/><path d="M168 168h304v168H168z" fill="{card}" stroke="{line}" stroke-width="2"/><path d="M208 224h80v112h-80zM336 224h96v64h-96z" fill="{soft}" stroke="{ink}" stroke-width="2"/><path d="M136 168h368" stroke="{ink}" stroke-width="2"/><circle cx="384" cy="256" r="14" fill="{P['green']}"/>'''
    elif kind=='billing':
        art=f'''<rect x="152" y="96" width="232" height="240" rx="16" fill="{card}" stroke="{ink}" stroke-width="2"/><rect x="184" y="128" width="168" height="72" rx="8" fill="{soft}"/><text x="208" y="184" font-family="Inter,Arial" font-size="48" font-weight="700" fill="{ink}">₹</text><path d="M184 232h120M184 264h152M184 296h88" stroke="{line}" stroke-width="8"/><path d="M416 160h80v176l-16-10-16 10-16-10-16 10-16-10z" fill="#FFFFFF" stroke="{ink}" stroke-width="2"/><circle cx="456" cy="232" r="24" fill="{P['green']}"/><path d="m444 232 8 8 16-18" stroke="#fff" stroke-width="6" fill="none"/>'''
    elif kind=='backup':
        art=f'''<rect x="152" y="112" width="152" height="232" rx="16" fill="{card}" stroke="{ink}" stroke-width="2"/><rect x="168" y="144" width="120" height="152" rx="8" fill="{soft}"/><circle cx="228" cy="320" r="8" fill="{line}"/><path d="M344 256c-4-48 36-88 84-80 18-42 80-28 82 18 54 0 58 86 4 86H374c-32 0-46-38-30-62" fill="{card}" stroke="{ink}" stroke-width="2"/><path d="m428 252 28-28 28 28M456 226v70" stroke="{P['blue']}" stroke-width="12" fill="none"/>'''
    return svg(w,h,base+art)

def simple_illustration(theme,kind,status=False):
    dark=theme=='dark'; ink='#F4F6FC' if dark else P['navy']; card=P['darkcard'] if dark else P['card']; soft='#1B2942' if dark else P['soft']
    sym={'no-products':'M220 176h200v152H220z M220 176l100-64 100 64 M320 112v216','no-customers':'M272 192a48 48 0 1 0 96 0 48 48 0 1 0-96 0 M224 328c8-64 184-64 192 0','no-sales':'M232 120h176v224l-18-12-18 12-18-12-18 12-18-12-18 12-18-12-18 12-18-12-18 12V120 M272 184h96 M272 232h72','offline':'M208 208c64-64 160-64 224 0 M256 256c36-36 92-36 128 0 M320 312h1 M208 120l224 224','no-backup':'M208 288h224c56 0 56-88 0-88-16-72-120-72-136-8-56-8-80 72-32 96 M224 136l192 208','no-results':'M216 128h160v216H216z M248 184h96 M248 224h72 M392 288l56 56 M376 272a48 48 0 1 0 0 1','success':'M240 216l56 56 112-128','warning':'M320 104l144 248H176z M320 184v80 M320 312h1','error':'M224 128l192 192 M416 128 224 320','syncing':'M224 184a112 112 0 0 1 184-24l24 24 M432 128v56h-56 M416 272a112 112 0 0 1-184 24l-24-24 M208 328v-56h56'}[kind]
    color=P['green'] if kind=='success' else P['amber'] if kind=='warning' else P['red'] if kind=='error' else P['blue']
    body=f'<ellipse cx="320" cy="344" rx="160" ry="20" fill="{P["deep"]}" opacity=".1"/><circle cx="320" cy="232" r="144" fill="{soft}"/><path d="{sym}" fill="none" stroke="{color if status else ink}" stroke-width="12"/><circle cx="438" cy="126" r="18" fill="{color}"/>'
    return svg(640,400,body)

ICON_PATHS=['M4 10h16v10H4z M6 10V6h12v4','M4 8h16v12H4z M8 8V4h8v4','M5 4h14v16H5z M8 8h8 M8 12h8 M8 16h5','M4 12h16 M6 12V7h12v5 M8 16h1 M15 16h1','M4 10h16v10H4z M7 10l2-5h6l2 5','M4 6h16v14H4z M8 10h8 M8 14h5']
def mini_icon(name,i,theme,fill=True):
    dark=theme=='dark'; ink='#F4F6FC' if dark else P['navy']; bg='#1B2942' if dark else P['soft']; path=ICON_PATHS[i%len(ICON_PATHS)]
    extra='';
    if i%4==0: extra=f'<circle cx="18" cy="6" r="3" fill="{P["green"]}"/>'
    return svg(24,24,f'<rect x="1" y="1" width="22" height="22" rx="6" fill="{bg}"/><path d="{path}" fill="none" stroke="{ink}" stroke-width="2"/>{extra}')

def text_asset(w,h,label,fg,bg,shape='pill'):
    rx=h/2 if shape=='pill' else 8
    return svg(w,h,f'<rect x="1" y="1" width="{w-2}" height="{h-2}" rx="{rx}" fill="{bg}" stroke="{fg}" stroke-width="2"/><text x="{w/2}" y="{h/2+5}" text-anchor="middle" font-family="Inter,Arial,sans-serif" font-size="14" font-weight="700" fill="{fg}">{esc(label)}</text>')

def all_assets():
    icon_assets()
    for theme in ('light','dark'):
        for key in ('business','billing','backup'): save(f'illustrations/{theme}/illus-onboarding-{key}.svg',scene(theme,key))
        for key in ('no-products','no-customers','no-sales','offline','no-backup','no-results'): save(f'illustrations/{theme}/empty-{key}.svg',simple_illustration(theme,key))
        for key in ('success','warning','error','syncing'): save(f'illustrations/{theme}/status-{key}.svg',simple_illustration(theme,key,True))
        mark=receipt_mark(fg_only=True); bg=P['dark'] if theme=='dark' else P['bg']; save(f'splash/splash-{theme}.svg',svg(1080,1920,f'<g transform="translate(284 704)">{mark}</g><text x="540" y="1280" text-anchor="middle" font-family="Inter,Arial" font-size="88" font-weight="700" fill="{("#F4F6FC" if theme=="dark" else P["navy"])}">BillNex</text>',bg),(1,))
    biz=['kirana','supermarket','pharmacy','restaurant','cafe-bakery','hardware','apparel','jewellery','electronics-mobile','stationery','salon-spa','repair-centre','wholesale-distribution','auto-parts-garage','optical','agri-input','fresh-produce-meat','laundry','gym-membership','rental','clinic-diagnostic','manufacturing','home-services','tuition-institute']
    features=['billing-pos','gst-tax','inventory-stock','credit-khata','purchasing-suppliers','reports-analytics','backup','roles-security','appointments','printing']
    payments=['cash','upi','card','bank','credit-khata']
    for theme in ('light','dark'):
        for i,n in enumerate(biz): save(f'biztypes/{theme}/biztype-{n}-24.svg',mini_icon(n,i,theme),(1,2,3))
        for i,n in enumerate(features): save(f'features/{theme}/feature-{n}.svg',mini_icon(n,i+2,theme),(1,2,3))
        for i,n in enumerate(payments): save(f'features/{theme}/payment-{n}.svg',mini_icon(n,i+4,theme),(1,2,3))
    badges=[('paid',P['green'],P['greenfill']),('pending',P['amber'],P['amberfill']),('low-stock',P['amber'],P['amberfill']),('out',P['red'],'#FDECEC'),('overdue',P['red'],'#FDECEC'),('new',P['deep'],P['soft'])]
    for n,fg,bg in badges: save(f'badges/badge-{n}.svg',text_asset(120,36,n.replace('-',' ').upper(),fg,bg),(1,2,3))
    save('invoice/stamp-paid.svg',text_asset(160,64,'✓  PAID',P['green'],P['greenfill'],'box'))
    save('invoice/stamp-due.svg',text_asset(160,64,'!  DUE',P['amber'],P['amberfill'],'box'))
    save('invoice/qr-frame.svg',svg(192,192,f'<rect x="8" y="8" width="176" height="176" rx="16" fill="none" stroke="{P["navy"]}" stroke-width="2"/><path d="M8 56V8h48 M136 8h48v48 M184 136v48h-48 M56 184H8v-48" fill="none" stroke="{P["blue"]}" stroke-width="8"/>'))
    save('invoice/watermark.svg',svg(512,512,f'<g opacity=".07">{receipt_mark(mono=True,fg_only=True)}</g>'))
    save('invoice/ornament-thermal.svg',svg(384,48,f'<path d="M0 24h144l16-16 16 16 16-16 16 16h176" fill="none" stroke="{P["blue"]}" stroke-width="2"/>'))
    save('invoice/ornament-a4.svg',svg(800,64,f'<rect width="800" height="16" rx="8" fill="{P["blue"]}"/><rect y="24" width="240" height="8" rx="4" fill="{P["green"]}"/>'))
    for n,i in [('customer',1),('supplier',2),('product',3),('shop',4)]:
        save(f'badges/placeholder-{n}.svg',svg(96,96,f'<rect x="1" y="1" width="94" height="94" rx="24" fill="{P["soft"]}"/><g transform="translate(0 0) scale(4)"><path d="{ICON_PATHS[i]}" fill="none" stroke="{P["navy"]}" stroke-width="2"/></g>'))
    store=f'''<rect width="1024" height="500" fill="{P['blue']}"/><circle cx="884" cy="72" r="200" fill="{P['deep']}"/><text x="72" y="144" font-family="Inter,Arial" font-size="72" font-weight="700" fill="#fff">Bill. Track. Grow.</text><text x="72" y="208" font-family="Inter,Arial" font-size="28" fill="#fff">Billing made simple for every Indian business</text><g transform="translate(620 0) scale(.82)">{receipt_mark()}</g><rect x="72" y="280" width="320" height="88" rx="16" fill="#fff"/><text x="232" y="336" text-anchor="middle" font-family="Inter,Arial" font-size="28" font-weight="700" fill="{P['navy']}">Fast • GST-ready • Secure</text>'''
    save('store/play-feature-1024x500.svg',svg(1024,500,store),(1,))
    frame=f'<rect x="40" y="8" width="280" height="624" rx="40" fill="{P["navy"]}"/><rect x="52" y="24" width="256" height="592" rx="28" fill="{P["bg"]}"/><rect x="128" y="36" width="104" height="20" rx="10" fill="{P["navy"]}"/><rect x="76" y="96" width="208" height="88" rx="16" fill="#fff"/><rect x="76" y="208" width="96" height="96" rx="16" fill="{P["soft"]}"/><rect x="188" y="208" width="96" height="96" rx="16" fill="{P["soft"]}"/>'
    save('store/screenshot-frame.svg',svg(360,640,frame),(1,2,3))

def contact_sheet():
    files=sorted(ROOT.rglob('*@1x.png')); thumbs=[]
    for f in files:
        try:
            im=Image.open(f).convert('RGBA'); im.thumbnail((144,96)); thumbs.append((f,im))
        except Exception: pass
    cols=6; cellw,cellh=184,136; rows=math.ceil(len(thumbs)/cols); sheet=Image.new('RGB',(cols*cellw,rows*cellh),P['bg']); d=ImageDraw.Draw(sheet)
    font=ImageFont.load_default()
    for idx,(f,im) in enumerate(thumbs):
        x=(idx%cols)*cellw; y=(idx//cols)*cellh; sheet.paste(im,(x+20,y+8),im); label=str(f.relative_to(ROOT)).replace('\\','/')[-28:]; d.text((x+8,y+108),label,fill=P['navy'],font=font)
    sheet.save(ROOT/'contact-sheet.png'); sheet.save(ROOT/'contact-sheet.webp','WEBP',quality=90)

if __name__=='__main__':
    all_assets(); print(f'Generated SVG assets in {ROOT}')
