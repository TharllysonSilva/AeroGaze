"""Convert the supplied simple SVG geometry into Android vector resources.

No raster editing or remote dependencies. The source SVG is kept unchanged.
Supported input elements: svg, g, rect, circle and path, without transforms.
"""
from pathlib import Path
import xml.etree.ElementTree as ET

ROOT = Path(__file__).resolve().parents[1]
RES = ROOT / 'android/app/src/main/res'
SVG = ROOT / 'assets/branding/aerogaze-icon.svg'
NS = 'http://schemas.android.com/apk/res/android'
ET.register_namespace('android', NS)


def attr(name):
    return f'{{{NS}}}{name}'


def write_xml(path, node):
    path.parent.mkdir(parents=True, exist_ok=True)
    ET.indent(node, space='    ')
    ET.ElementTree(node).write(path, encoding='utf-8', xml_declaration=True)


def geometry(element):
    tag = element.tag.rsplit('}', 1)[-1]
    if tag == 'path':
        return element.attrib['d']
    if tag == 'circle':
        x, y, r = (float(element.get(k, '0')) for k in ('cx', 'cy', 'r'))
        return f'M{x-r},{y} A{r},{r} 0,1,0 {x+r},{y} A{r},{r} 0,1,0 {x-r},{y} Z'
    if tag == 'rect':
        x, y, w, h = (float(element.get(k, '0')) for k in ('x', 'y', 'width', 'height'))
        r = float(element.get('rx', '0'))
        return (f'M{x+r},{y} H{x+w-r} A{r},{r} 0,0,1 {x+w},{y+r} '
                f'V{y+h-r} A{r},{r} 0,0,1 {x+w-r},{y+h} H{x+r} '
                f'A{r},{r} 0,0,1 {x},{y+h-r} V{y+r} A{r},{r} 0,0,1 {x+r},{y} Z')
    raise ValueError(f'Unsupported SVG geometry: {tag}')


def paths(node, inherited=None):
    style = dict(inherited or {'fill': '#000000'})
    style.update(node.attrib)
    tag = node.tag.rsplit('}', 1)[-1]
    if tag in ('metadata', 'title', 'desc'):
        return []
    if 'transform' in node.attrib:
        raise ValueError('SVG transforms must be implemented before regenerating')
    if tag in ('svg', 'g'):
        return [item for child in node for item in paths(child, style)]
    if tag not in ('path', 'rect', 'circle'):
        raise ValueError(f'Unsupported SVG element: {tag}')
    data = {attr('pathData'): geometry(node)}
    for key, target in [('fill', 'fillColor'), ('stroke', 'strokeColor'),
                        ('stroke-width', 'strokeWidth'), ('stroke-linecap', 'strokeLineCap'),
                        ('stroke-linejoin', 'strokeLineJoin')]:
        value = style.get(key)
        if value is not None:
            data[attr(target)] = '#00000000' if value == 'none' else value
    if 'opacity' in style:
        data[attr('fillAlpha')] = style['opacity']
        data[attr('strokeAlpha')] = style['opacity']
    return [(tag, data)]


def vector(items, size, viewport=512, inset=False):
    node = ET.Element('vector', {attr('width'): f'{size}dp', attr('height'): f'{size}dp',
                                attr('viewportWidth'): str(viewport), attr('viewportHeight'): str(viewport)})
    parent = node
    if inset:
        parent = ET.SubElement(node, 'group', {attr('scaleX'): '.75', attr('scaleY'): '.75',
                                             attr('translateX'): '64', attr('translateY'): '64'})
    elif viewport == 768:
        parent = ET.SubElement(node, 'group', {attr('translateX'): '128', attr('translateY'): '128'})
    for _, data in items:
        ET.SubElement(parent, 'path', data)
    return node


def main():
    items = paths(ET.parse(SVG).getroot())
    foreground = [item for item in items if item[0] != 'rect']
    write_xml(RES / 'mipmap-anydpi/ic_launcher.xml', vector(items, 48))
    write_xml(RES / 'drawable/aerogaze_icon_tile.xml', vector(items, 96))
    write_xml(RES / 'drawable/aerogaze_icon_foreground.xml', vector(foreground, 108, inset=True))
    write_xml(RES / 'drawable/aerogaze_splash_logo.xml', vector(items, 288, viewport=768))
    monochrome = []
    for tag, original in foreground:
        data = dict(original)
        for key in ('fillColor', 'strokeColor'):
            if data.get(attr(key)) not in (None, '#00000000'):
                data[attr(key)] = '#FFFFFFFF'
        monochrome.append((tag, data))
    write_xml(RES / 'drawable/aerogaze_icon_monochrome.xml', vector(monochrome, 108, inset=True))
    for qualifier in ('v26', 'v33'):
        adaptive = ET.Element('adaptive-icon')
        ET.SubElement(adaptive, 'background', {attr('drawable'): '@color/aerogaze_icon_background'})
        ET.SubElement(adaptive, 'foreground', {attr('drawable'): '@drawable/aerogaze_icon_foreground'})
        if qualifier == 'v33':
            ET.SubElement(adaptive, 'monochrome', {attr('drawable'): '@drawable/aerogaze_icon_monochrome'})
        write_xml(RES / f'mipmap-anydpi-{qualifier}/ic_launcher.xml', adaptive)
    print('Android vector icons and splash logo generated from the supplied SVG.')


if __name__ == '__main__':
    main()
