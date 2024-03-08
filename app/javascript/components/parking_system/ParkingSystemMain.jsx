import React, { useEffect, useState } from 'react';

const getCurrentDateTime = () => {
  const now = new Date();
  const year = now.getFullYear();
  const month = String(now.getMonth() + 1).padStart(2, '0'); // Months are zero-based
  const day = String(now.getDate()).padStart(2, '0');
  const hours = String(now.getHours()).padStart(2, '0');
  const minutes = String(now.getMinutes()).padStart(2, '0');

  return `${year}-${month}-${day}T${hours}:${minutes}`;
};

const convertSize = (size) => {
  switch (size) {
    case 0:
      return 'S';
    case 1:
      return 'M';
    case 2:
      return 'L';
    default:
      return 's';
  }
};
const ParkingSystemMain = () => {
  // const [parkingSystem, setParkingSystem] = useState(parkingDetails);
  const [freeSlots, setFreeSlots] = useState([]);
  const [occupiedSlots, setOccupiedSlots] = useState([]);
  const [entryPoints, setEntryPoints] = useState([]);
  const [unparkCurrent, setUnparkCurrent] = useState('');
  const [exitTime, setExitTime] = useState(getCurrentDateTime());
  const [message, setMessage] = useState('');
  const [showAlert, setShowAlert] = useState({
    error: false,
    success: false,
    unparkSuccess: false,
  });

  useEffect(() => {
    fetchAll();
    // fetchAvalableParking();
    // fetchOccupiedSlots();
  }, []);

  const fetchAll = () => {
    fetchAvalableParking();
    fetchOccupiedSlots();
    fetchEntryPoints();
  };

  const fetchAvalableParking = async () => {
    const url = '/parking-slot/free-slots';
    await fetch(url, {
      method: 'GET',
      'X-CSRF-Token': document.head.querySelector('meta[name="csrf-token"]'),
    })
      .then((response) => response.json())
      .then((data) => {
        setFreeSlots(data);
      });
  };

  const fetchOccupiedSlots = async () => {
    const url = '/parking-slot/occupied-slots';
    await fetch(url, {
      method: 'GET',
      'X-CSRF-Token': document.head.querySelector('meta[name="csrf-token"]'),
    })
      .then((response) => response.json())
      .then((data) => {
        console.log(data);
        setOccupiedSlots(data);
      });
  };

  const fetchEntryPoints = async () => {
    const url = '/entry-point';
    await fetch(url, {
      method: 'GET',
      'X-CSRF-Token': document.head.querySelector('meta[name="csrf-token"]'),
    })
      .then((response) => response.json())
      .then((data) => {
        setEntryPoints(data);
      });
  };

  const submitVehicleParking = (e) => {
    e.preventDefault();
    setMessage('');

    const formData = new FormData(e.currentTarget);
    const responseBody = {};
    formData.forEach((value, property) => (responseBody[property] = value));

    const url = '/vehicle/park';
    fetch(url, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': document.head.querySelector('meta[name="csrf-token"]')
          .content,
      },
      body: JSON.stringify(responseBody),
    })
      .then((response) => response.json())
      .then((data) => {
        fetchAll();
        setMessage(data.message);

        if (data.success) {
          setShowAlert({ error: false, success: true, unparkSuccess: false });
        } else {
          setShowAlert({ error: true, success: false, unparkSuccess: false });
        }

        setTimeout(() => {
          setShowAlert({ error: false, success: false, unparkSuccess: false });
        }, 5000);
      })
      .catch((error) => {
        console.error('Error:', error);
      });
  };

  const unparkVehicle = (plateNumber) => {
    setMessage('');

    const url = '/vehicle/unpark';
    fetch(url, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': document.head.querySelector('meta[name="csrf-token"]')
          .content,
      },
      body: JSON.stringify({
        plate_number: plateNumber,
        checkout_time: exitTime,
      }),
    })
      .then((response) => response.json())
      .then((data) => {
        fetchAll();

        setMessage(data);
        if (data.success) {
          setShowAlert({ error: false, success: false, unparkSuccess: true });
        } else {
          setShowAlert({ error: true, success: false, unparkSuccess: false });
        }
        // if (data.errors.length == 0) {
        //   localStorage.setItem(vehicleId, exitTime);
        //   setUnparkCurrent('');
        //   setExitTime('');
        // }

        // if (data.errors.length > 0) {
        //   setShowAlert({ error: true, success: false, unparkSuccess: false });
        // }

        // if (data.messages && Object.keys(data.messages).length > 0) {
        //   setShowAlert({ error: false, success: false, unparkSuccess: true });
        // }

        setTimeout(() => {
          setShowAlert({ error: false, success: false, unparkSuccess: false });
        }, 5000);

        // setParkingSystem(data);
      })
      .catch((error) => {
        console.error('Error:', error);
      });
  };

  return (
    <main>
      <section className='parking-main'>
        <div className='parking-main-header'>
          <span>Available parking slots</span>
        </div>
        <div className='parking-container'>
          {freeSlots.map((data) => (
            <div key={data.id} className='parking-slot'>
              <div className='parking-slot-cell'>
                <span
                  className={`indicator${
                    data.occupied ? ' occupied' : ' available'
                  }`}
                >
                  &#8226;
                </span>
                <div className='parking-details'>
                  <span>
                    <strong>{data.name}</strong>
                  </span>
                  <span className='parking-slot-size'>
                    {convertSize(data.size)}
                  </span>
                </div>
              </div>
            </div>
          ))}
          {/* {Object.entries(parkingSystem?.slot_sizes || {}).map(
            ([key, value]) => (
              <div key={key} className='parking-slot'>
                <div className='parking-header'>
                  <span>
                    Parking size: <strong>{key}</strong>
                  </span>
                </div>
                <div className='parking-content'>
                  {value.map((value) => (
                    <div
                      key={value}
                      className='parking-content-cell'
                      title={parkingSystem?.parking_slots[value]}
                    >
                      <span>{value}</span>
                    </div>
                  ))}
                </div>
              </div>
            )
          )} */}
        </div>
      </section>
      <hr />
      <section className='parking-main'>
        <div className='parking-main-header'>
          <span>Occupied parking slots</span>
        </div>
        <div className='parking-container'>
          {occupiedSlots.map((data) => (
            <div key={data.id} className='parking-slot'>
              <div className='parking-slot-cell'>
                <span
                  className={`indicator${
                    data.occupied ? ' occupied' : ' available'
                  }`}
                >
                  &#8226;
                </span>
                <div className='parking-details'>
                  <span>
                    <strong>{data.name}</strong>
                  </span>
                  <span>
                    <strong>{data.plate_number}</strong>
                  </span>
                  <span className='parking-slot-size'>
                    {convertSize(data.size)}
                  </span>
                </div>
              </div>
              <button
                className='unpark-button'
                type='button'
                onClick={() => {
                  setUnparkCurrent(data.plate_number);
                }}
              >
                Unpark
              </button>
              {unparkCurrent == data.plate_number && (
                <div className='unpark-options'>
                  <input
                    type='datetime-local'
                    name='exit_time'
                    id='exit_time'
                    value={exitTime || getCurrentDateTime()}
                    onChange={(e) => setExitTime(e.target.value)}
                  />
                  <button
                    onClick={() => {
                      unparkVehicle(data.plate_number);
                      setExitTime('');
                    }}
                  >
                    Submit
                  </button>
                  <button
                    onClick={() => {
                      setUnparkCurrent('');
                      setExitTime('');
                    }}
                  >
                    Close
                  </button>
                </div>
              )}
            </div>
          ))}
        </div>
        {/* {Object.entries(parkingSystem.parked_vehicles).map(([k, v]) => (
          <div className='parked-main' key={k}>
            <div className='parked-main-title'>
              <span>Entry point: {k}</span>
            </div>
            {Object.entries(v).map(([k, v]) => (
              <div className='parked-main-content' key={v.vehicle_id}>
                <div>
                  <span>
                    Vehicle ID: <strong>{v.vehicle_id}</strong>
                  </span>
                </div>
                <div>
                  <span>
                    Parking slot: <strong>{k}</strong>
                  </span>
                </div>
                <div>
                  <span>
                    Entry time: <strong>{v.entry_time}</strong>
                  </span>
                </div>
                <button
                  className='unpark-button'
                  type='button'
                  onClick={() => {
                    setUnparkCurrent(v.vehicle_id);
                    setExitTime(getCurrentDateTime());
                  }}
                >
                  Unpark
                </button>
                {unparkCurrent == v.vehicle_id && (
                  <div className='unpark-options'>
                    <input
                      type='datetime-local'
                      name='exit_time'
                      id='exit_time'
                      value={exitTime || getCurrentDateTime()}
                      onChange={(e) => setExitTime(e.target.value)}
                    />
                    <button onClick={() => unparkVehicle(v.vehicle_id)}>
                      Submit
                    </button>
                    <button
                      onClick={() => {
                        setUnparkCurrent('');
                        setExitTime('');
                      }}
                    >
                      Close
                    </button>
                  </div>
                )}
              </div>
            ))}
          </div>
        ))} */}
      </section>
      <hr />

      {showAlert.error && (
        <div className='alert-message error'>
          <span className='alert-message-content error'>{message}</span>
        </div>
      )}

      {showAlert.success && (
        <div className='alert-message'>
          <span className='alert-message-content'>{message}</span>
        </div>
      )}

      {showAlert.unparkSuccess && (
        <div className='alert-message'>
          <span className='alert-message-content'>{message.message}</span>
          <ul>
            <li>Duration: {message.duration}</li>
            <li>
              Total fee: <strong>{message.total_fee}</strong>
            </li>
          </ul>
        </div>
      )}

      <section>
        <div>
          {entryPoints.map((entry, index) => (
            <form
              className='parking-form'
              onSubmit={submitVehicleParking}
              key={index}
            >
              <input
                hidden
                type='text'
                name='entry_point_name'
                id='entry_point_name'
                value={entry}
              />
              <div className='parking-form-title'>{entry}</div>
              <div className='parking-form-inputs'>
                <div className='parking-form-inputs-container'>
                  <div>
                    <label htmlFor='plate_number'>Vehicle number: </label>
                    <input type='text' name='plate_number' id='plate_number' />
                  </div>
                  <select name='size' id='size'>
                    <option value={0}>Small vehicle</option>
                    <option value={1}>Medium vehicle</option>
                    <option value={2}>Large vehicle</option>
                  </select>
                  <input
                    type='datetime-local'
                    name='checkin_time'
                    id='checkin_time'
                    value={exitTime || getCurrentDateTime()}
                    onChange={(e) => setExitTime(e.target.value)}
                  />
                  <button type='submit'>Park</button>
                </div>
              </div>
            </form>
          ))}
        </div>
      </section>
    </main>
  );
};

export default ParkingSystemMain;
