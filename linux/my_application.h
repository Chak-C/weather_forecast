#ifndef FLUTTER__APPLICATION_H_
#define FLUTTER__APPLICATION_H_

#include <gtk/gtk.h>

G_DECLARE_FINAL_TYPE(Application, _application, , APPLICATION,
                     GtkApplication)

/**
 * _application_new:
 *
 * Creates a new Flutter-based application.
 *
 * Returns: a new #Application.
 */
Application* _application_new();

#endif  // FLUTTER__APPLICATION_H_
