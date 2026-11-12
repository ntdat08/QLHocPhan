
const { initializeApp, cert } = require("firebase-admin/app");
const { getFirestore, Timestamp, GeoPoint, DocumentReference } =
  require("firebase-admin/firestore");
const fs = require("fs");

const serviceAccount = require("./serviceAccountKey.json");

// Khởi tạo Firebase Admin
initializeApp({
  credential: cert(serviceAccount),
});

const db = getFirestore();

// Chuyển dữ liệu Firestore sang JSON
function convertData(data) {
  if (data instanceof Timestamp) {
    return data.toDate().toISOString();
  }

  if (data instanceof GeoPoint) {
    return {
      latitude: data.latitude,
      longitude: data.longitude,
    };
  }

  if (data instanceof DocumentReference) {
    return data.path;
  }

  if (Array.isArray(data)) {
    return data.map(convertData);
  }

  if (data && typeof data === "object") {
    const result = {};

    for (const key of Object.keys(data)) {
      result[key] = convertData(data[key]);
    }

    return result;
  }

  return data;
}

// Xuất collection và subcollection
async function exportCollection(collectionRef) {
  const snapshot = await collectionRef.get();
  const result = {};

  for (const doc of snapshot.docs) {
    const subcollections = await doc.ref.listCollections();
    const subcollectionData = {};

    for (const subcollection of subcollections) {
      subcollectionData[subcollection.id] =
        await exportCollection(subcollection);
    }

    result[doc.id] = {
      data: convertData(doc.data()),
      subcollections: subcollectionData,
    };
  }

  return result;
}

// Xuất toàn bộ Firestore
async function main() {
  try {
    const collections = await db.listCollections();
    const database = {};

    for (const collection of collections) {
      console.log("Đang xuất:", collection.id);

      database[collection.id] =
        await exportCollection(collection);
    }

    fs.writeFileSync(
      "firestore_data.json",
      JSON.stringify(database, null, 2),
      "utf8"
    );

    console.log("Đã xuất dữ liệu Firestore thành công!");
  } catch (error) {
    console.error("Lỗi khi xuất dữ liệu:", error);
  }
}

main();
