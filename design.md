# PSIREG — Sistema visual institucional Sunset

## 1. Dirección visual

PSIREG utiliza una adaptación institucional de la paleta de atardecer de Mistral AI.
El sitio conserva una interfaz sobria y legible, pero reemplaza el fondo blanco por
una combinación cálida de crema, amarillo y naranja.

Regla obligatoria:

- El fondo general nunca debe ser blanco puro (`#ffffff`) ni negro puro (`#000000`).
- Blanco y negro pueden aparecer como texto o en controles puntuales.
- El naranja se reserva para acciones principales, foco y estados activos.
- El gradiente sunset se usa en el hero, encabezados de tabla y banda del footer.

## 2. Paleta

| Token | Valor | Uso |
|---|---:|---|
| `primary` | `#cc3a05` | Botones principales, enlaces y foco con contraste AA |
| `primary-deep` | `#8f2600` | Estado activo y extremo profundo del gradiente |
| `sunshine` | `#ffd900` | Luz amarilla del gradiente |
| `sunshine-mid` | `#ffa110` | Transición amarilla–naranja |
| `sunset` | `#ff8105` | Naranja intermedio |
| `canvas` | `#fff8e0` | Base crema del sitio |
| `surface-soft` | `#fffaeb` | Tarjetas, campos y tablas |
| `surface-strong` | `#fff0c2` | Footer, hover y mensajes |
| `hairline` | `#e6d5a8` | Bordes suaves |
| `hairline-strong` | `#c9ad6b` | Bordes de campos |
| `ink` | `#1f1f1f` | Texto principal |
| `body` | `#4a4a4a` | Texto secundario |

## 3. Fondo

El `body` combina dos gradientes radiales suaves y un gradiente lineal crema.
La intención es mantener profundidad sin afectar la lectura:

```css
background:
    radial-gradient(circle at 12% 5%, rgba(255, 217, 0, .22), transparent 30rem),
    radial-gradient(circle at 90% 18%, rgba(250, 82, 15, .12), transparent 34rem),
    linear-gradient(145deg, #fff0c2 0%, #fff8e0 48%, #fffaeb 100%);
```

## 4. Tipografía

- Cuerpo y controles: `system-ui`, Segoe UI, Roboto y Arial.
- Títulos: `SF Pro Rounded` con `system-ui` como respaldo.
- Cuerpo: `16px`, interlineado `1.5`.
- Títulos: peso `600`, interlineado `1.2`.
- Formularios: familia `ui-sans-serif` y texto secundario `#4a4a4a`.

## 5. Geometría

- Botones y campos: radio de `8px`.
- Tarjetas: radio de `12px`.
- Hero principal: radio de `20px`.
- Badges: radio completo tipo píldora.
- No utilizar píldoras para botones normales.
- Mantener bordes de `1px` y evitar sombras pesadas.

## 6. Componentes

### Botón principal

- Fondo `#cc3a05`.
- Texto blanco.
- Estado activo `#8f2600`.
- Radio `8px`.

### Botón secundario

- Fondo `#fffaeb`.
- Borde `#c9ad6b`.
- Texto `#1f1f1f`.

### Tarjetas

- Fondo marfil translúcido.
- Borde `#e6d5a8`.
- Radio `12px`.
- Sin sombras decorativas.

### Formularios

- Fondo de campos `#fffaeb`.
- Foco naranja con aro translúcido.
- Panel centrado de máximo `560px`.
- Mensajes de éxito, error y advertencia mantienen colores semánticos sobre superficies cálidas.

### Tablas

- Fondo de datos `#fffaeb`.
- Encabezado con gradiente rojo profundo para mantener texto blanco legible.
- Texto blanco en encabezados.
- Hover crema profundo.
- Scroll horizontal en pantallas pequeñas.

### Hero

- Gradiente `#ffd900 → #ffa110 → #ff8105 → #fa520f`.
- Texto oscuro para mantener contraste.
- Acción principal oscura únicamente dentro del hero.

### Footer

- Fondo `#fff0c2`.
- Banda superior sunset:
  `#8f2600 → #cc3a05 → #fa520f → #ff8105 → #ffa110 → #ffd900 → #fff8e0`.

## 7. Responsive

### Hasta 768px

- Menú apilado.
- Cuadrículas en una columna.
- Hero con padding reducido.
- Tablas con desplazamiento horizontal.

### Hasta 460px

- Ocultar subtítulo de marca.
- Reducir separaciones del menú.
- Conservar botones y campos con área táctil suficiente.

## 8. Accesibilidad

- Mantener texto principal oscuro sobre superficies crema.
- Usar texto blanco solamente sobre naranja profundo.
- No comunicar estados únicamente mediante color; conservar texto visible.
- Todos los campos deben tener `label`.
- El foco debe permanecer claramente visible.

## 9. Fuente de referencia

La paleta y el gradiente sunset se adaptaron desde `DESIGN-mistral.ai.md`.
La implementación final se encuentra en:

- `css/layout.css`
- `css/formularios.css`
- `css/tablas.css`
