# BillingCore

Una librería de Elixir para la generación y firma digital de documentos de facturación electrónica para Ecuador.

## Descripción

BillingCore proporciona una solución completa para generar y firmar documentos XML de facturación electrónica conforme a los requisitos del Servicio de Rentas Internas (SRI) de Ecuador.

### Características actuales

- Generación de facturas electrónicas
- Firma digital de documentos XML
- Validación de estructura de documentos

### Próximamente

- Soporte para notas de crédito
- Soporte para notas de débito
- Soporte para retenciones
- Soporte para guías de remisión
- Soporte para comprobantes de retención

## Instalación

La librería aún no está publicada en Hex. Para usarla, agrega lo siguiente a tu lista de dependencias en `mix.exs`:
```elixir
def deps do
  [
    {:billing_core, github: "joselo/billing-core", branch: "master"}
  ]
end
```

Luego ejecuta:
```bash
mix deps.get
```

## Uso básico

Documentación detallada próximamente.

## Requisitos

- Elixir 1.12 o superior
- Certificado digital válido para firma electrónica

## Estado del proyecto

Este proyecto se encuentra en desarrollo activo. La API puede cambiar sin previo aviso hasta la versión 1.0.0.

## Contribuciones

Las contribuciones son bienvenidas. Por favor, abre un issue para discutir cambios mayores antes de enviar un pull request.

## Licencia

Este proyecto está licenciado bajo la Licencia MIT. Ver el archivo [LICENSE](LICENSE) para más detalles.

## Contacto

Para preguntas o soporte, por favor abre un issue en el repositorio de GitHub.
