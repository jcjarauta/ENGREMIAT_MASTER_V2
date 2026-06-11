# Control Consumer Contract

## Funcion

Permite que Control consuma salidas locales de Constructor sin escritura real en Control.

## Permitido

- Leer indices locales.
- Crear cola local.
- Crear reportes locales.

## Bloqueado

- Escritura real en Control.
- API externa.
- Worker real.
- Browser.
- Clipboard.
