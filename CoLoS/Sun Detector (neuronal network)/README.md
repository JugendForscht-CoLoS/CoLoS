#  Automatische Sonnenerkennung durch Machine-Learning

Hier wird die Sonne mittels des neuronalen Netzes erkannt. `MLManager` ist eine Klasse, welche als Schnittstelle zum neuronalen Netz dient. Ein gegebener PixelBuffer wird so verändert, dass er für das neuronale Netz lesbar ist. Die Klasse gibt dann ein `CGRect` zurück, welches die "Region" der Sonne bezeichnet.
