/**
 * Speichert den aktuell angemeldeten Benutzer für den aktuellen Thread.
 */
public class SecurityContext {
    
    private static final ThreadLocal<User> currentUser = new ThreadLocal<>();

    public static void login(User user) {
        if (user == null) {
            throw new IllegalArgumentException("Benutzer darf nicht null sein.");
        }
        currentUser.set(user);
    }

    public static void logout() {
        currentUser.remove();
    }

    public static User getCurrentUser() {
        User user = currentUser.get();
        if (user == null) {
            throw new IllegalStateException("Kein Benutzer im SecurityContext angemeldet.");
        }
        return user;
    }
}