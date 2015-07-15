public class Utils {

    public static Boolean isCurrentUserAdmin() {
        Id adminProfId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'][0].Id;
        return adminProfId == UserInfo.getProfileId();
    }

    public static Map<Id, List<sObject>> splitListBySpecialKey(List<sObject> sourceList, String key) {
        if (sourceList == null) {
            throw new IncorrectParameterException('ERROR: Utils.splitListBySpecialKey(sourceList, key) got incorrect first parameter.');
        }
        if (String.isBlank(key)) {
            throw new IncorrectParameterException('ERROR: Utils.splitListBySpecialKey(sourceList, key) got incorrect second parameter.');
        }
        Map<Id, List<sObject>> result = new Map<Id, List<sObject>>();
        List<sObject> tmpObjs;
        for (sObject obj : sourceList) {
            tmpObjs = new List<sObject>();
            if (obj.get(key) != null && result.containsKey((Id)obj.get(key))) {
                tmpObjs = result.get((Id)obj.get(key));
                tmpObjs.add(obj);
                result.put((Id)obj.get(key), tmpObjs);
            } else if (obj.get(key) != null) {
                tmpObjs.add(obj);
                result.put((Id)obj.get(key), tmpObjs);
            }
        }
        return result;
    }
    public class IncorrectParameterException extends System.Exception {}
}