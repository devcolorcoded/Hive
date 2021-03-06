package coloredcoded.hive.client;

public class UtilityBelt {
	
	public static void checkStringNotEmpty(String str) {
		checkNotNull(str);
		trueOrFail(!str.isEmpty());
	}

	public static void checkNotNull(Object obj) {
		trueOrFail(obj != null);
	}

	public static void trueOrFail(boolean truth) {
		if (!truth) {
			throw new IllegalArgumentException();
		}
	}

	public static String pluralOrSingular(int num, String word) {
		if (num == 1) {
			return word.substring(0, word.length()-1);
		}
		return word;
	}

	public static boolean isValidEmail(String email) {
		return !email.contains(" ") && email.contains("@") && email.contains(".");
	}

	public static boolean isValidUsername(String username) {
		return !username.isEmpty() && username.matches("^[a-zA-Z0-9]*$");
	}

}
