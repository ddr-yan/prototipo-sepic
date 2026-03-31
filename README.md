# Prototipo de convertidor SEPIC con UC3843

Este repositorio contiene el diseño, modelado y validación experimental de un convertidor DC-DC tipo SEPIC operando en alta frecuencia bajo control en modo corriente.

El proyecto combina análisis teórico, dimensionamiento de componentes, implementación física y evaluación experimental del prototipo.

---

## Descripción general

El trabajo desarrolla un convertidor SEPIC capaz de operar como elevador y reductor manteniendo una salida de polaridad positiva.

Se implementa un esquema de control en modo corriente pico utilizando el controlador UC3843, incluyendo lazo interno de corriente, lazo externo de voltaje y compensación de pendiente para garantizar estabilidad.

Posteriormente se construye un prototipo en protoboard y se comparan los resultados experimentales con los valores obtenidos mediante el modelo analítico.

---

## Contenido del repositorio

- **/docs/**  
  Documento técnico completo del proyecto.

- **/hardware/**  
  Esquemáticos y diseño del convertidor SEPIC.

- **/calculos/**  
  Desarrollo analítico y ecuaciones de diseño.

- **/mediciones/**  
  Capturas de osciloscopio y resultados experimentales.

---

## Arquitectura del sistema

1. **Etapa de potencia:**  
   Convertidor SEPIC con inductores L1 y L2, capacitor de acoplamiento, MOSFET de conmutación y diodo de rectificación.

2. **Etapa de control:**  
   Controlador UC3843 en modo corriente con:
   - Sensado de corriente (RCS)  
   - Compensación de pendiente  
   - Red de compensación tipo II  
   - Control PWM de frecuencia fija  

---

## Resultados experimentales

El prototipo permite validar el funcionamiento general de la topología SEPIC, aunque con limitaciones prácticas.

- Regulación obtenida: **12 V a ~1 A**  
- No se alcanza la corriente nominal de diseño (2 A)  
- Rizado medido: ~400 mV (superior al valor esperado)

Las mediciones muestran influencia significativa de ruido y efectos parásitos asociados a la implementación en protoboard.

---

## Conclusiones

El modelo analítico permite dimensionar correctamente los componentes del convertidor.

El sistema implementado valida la operación del SEPIC y del control en modo corriente, aunque el desempeño real se ve limitado por efectos no ideales del montaje.

---

## Recomendaciones para futuros desarrollos

- Implementar el diseño en PCB para reducir parásitos  
- Optimizar el layout de tierras y trayectorias de corriente  
- Mejorar el filtrado y reducir EMI  
- Realizar un análisis en frecuencia del lazo de control  
